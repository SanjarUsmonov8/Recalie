import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

const _createImageAnnotationStrokesIfMissing = '''
CREATE TABLE IF NOT EXISTS image_annotation_strokes (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  picture_id INTEGER NOT NULL REFERENCES group_pictures (id),
  tool TEXT NOT NULL,
  is_straight INTEGER NOT NULL CHECK (is_straight IN (0, 1)),
  thickness REAL NOT NULL,
  opacity REAL NOT NULL,
  color_value INTEGER NOT NULL,
  normalized_points BLOB NOT NULL,
  created_at INTEGER NOT NULL
)
''';

const _createImageNotesIfMissing = '''
CREATE TABLE IF NOT EXISTS image_notes (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  picture_id INTEGER NOT NULL REFERENCES group_pictures (id),
  normalized_x REAL NOT NULL,
  normalized_y REAL NOT NULL,
  content TEXT NOT NULL,
  image_bytes BLOB,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
)
''';

const _createGroupAttachmentsIfMissing = '''
CREATE TABLE IF NOT EXISTS group_attachments (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  picture_group_id INTEGER NOT NULL REFERENCES picture_groups (id),
  type TEXT NOT NULL,
  display_name TEXT NOT NULL,
  data BLOB NOT NULL,
  position INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
)
''';

const _createMemorySetGroupsIfMissing = '''
CREATE TABLE IF NOT EXISTS memory_set_groups (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  cover_image_bytes BLOB,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
)
''';

class AppPreferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class MemorySetGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BlobColumn get coverImageBytes => blob().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class PictureGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get setNumber => integer().nullable()();
  TextColumn get name => text()();
  TextColumn get textContent => text().nullable()();
  TextColumn get planType =>
      text().withDefault(const Constant('most_effective'))();
  DateTimeColumn get planStartDate => dateTime().nullable()();
  TextColumn get coverIcon => text().nullable()();
  TextColumn get coverColorStart => text().nullable()();
  TextColumn get coverColorEnd => text().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  IntColumn get memorySetGroupId =>
      integer().nullable().references(MemorySetGroups, #id)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class GroupPictures extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pictureGroupId => integer().references(PictureGroups, #id)();
  BlobColumn get imageBytes => blob()();
  IntColumn get position => integer().withDefault(const Constant(0))();
  BoolColumn get isReviewed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

class RecallEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pictureGroupId => integer().references(PictureGroups, #id)();
  DateTimeColumn get recalledAt => dateTime()();
}

class ImageAnnotationStrokes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pictureId => integer().references(GroupPictures, #id)();
  TextColumn get tool => text()();
  BoolColumn get isStraight => boolean()();
  RealColumn get thickness => real()();
  RealColumn get opacity => real()();
  IntColumn get colorValue => integer()();
  BlobColumn get normalizedPoints => blob()();
  DateTimeColumn get createdAt => dateTime()();
}

class ImageNotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pictureId => integer().references(GroupPictures, #id)();
  RealColumn get normalizedX => real()();
  RealColumn get normalizedY => real()();
  TextColumn get content => text()();
  BlobColumn get imageBytes => blob().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class GroupAttachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pictureGroupId => integer().references(PictureGroups, #id)();
  TextColumn get type => text()();
  TextColumn get displayName => text()();
  BlobColumn get data => blob()();
  IntColumn get position => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(
  tables: [
    AppPreferences,
    MemorySetGroups,
    PictureGroups,
    GroupPictures,
    RecallEvents,
    ImageAnnotationStrokes,
    ImageNotes,
    GroupAttachments,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.defaults()
    : super(
        driftDatabase(
          name: 'recalie',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  Future<void> ensureImageNoteStorage() async {
    await customStatement(_createImageNotesIfMissing);
    await _ensureImageNotePhotoColumn();
  }

  Future<void> _ensureImageNotePhotoColumn() async {
    final columns = await customSelect('PRAGMA table_info(image_notes)').get();
    final hasColumn = columns.any(
      (row) => row.read<String>('name') == 'image_bytes',
    );
    if (!hasColumn) {
      await customStatement(
        'ALTER TABLE image_notes ADD COLUMN image_bytes BLOB',
      );
    }
  }

  Future<void> _ensureMemorySetGroupStorage() async {
    await customStatement(_createMemorySetGroupsIfMissing);
    final columns = await customSelect(
      'PRAGMA table_info(picture_groups)',
    ).get();
    final hasColumn = columns.any(
      (row) => row.read<String>('name') == 'memory_set_group_id',
    );
    if (!hasColumn) {
      await customStatement(
        'ALTER TABLE picture_groups ADD COLUMN memory_set_group_id '
        'INTEGER NULL REFERENCES memory_set_groups (id)',
      );
    }
  }

  @override
  int get schemaVersion => 12;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(pictureGroups);
        await migrator.createTable(groupPictures);
      }
      if (from < 3) {
        await migrator.addColumn(pictureGroups, pictureGroups.textContent);
        await migrator.addColumn(pictureGroups, pictureGroups.planType);
        await migrator.addColumn(pictureGroups, pictureGroups.planStartDate);
        await migrator.createTable(recallEvents);
      }
      if (from < 4) {
        await customUpdate(
          "UPDATE picture_groups SET plan_type = 'most_effective' "
          "WHERE plan_type = 'effective'",
        );
      }
      if (from < 5) {
        await migrator.addColumn(pictureGroups, pictureGroups.coverIcon);
        await migrator.addColumn(pictureGroups, pictureGroups.coverColorStart);
        await migrator.addColumn(pictureGroups, pictureGroups.coverColorEnd);
        await migrator.addColumn(pictureGroups, pictureGroups.coverImageUrl);
      }
      if (from < 6) {
        await migrator.addColumn(pictureGroups, pictureGroups.setNumber);
        await migrator.addColumn(groupPictures, groupPictures.position);
        await migrator.addColumn(groupPictures, groupPictures.isReviewed);
        await customUpdate(
          'UPDATE picture_groups AS current_group '
          'SET set_number = ('
          'SELECT COUNT(*) FROM picture_groups AS earlier_group '
          'WHERE earlier_group.id <= current_group.id'
          ')',
        );
        await customUpdate(
          'UPDATE group_pictures AS current_picture '
          'SET position = ('
          'SELECT COUNT(*) FROM group_pictures AS earlier_picture '
          'WHERE earlier_picture.picture_group_id = '
          'current_picture.picture_group_id '
          'AND earlier_picture.id <= current_picture.id'
          ')',
        );
      }
      if (from < 7) {
        await migrator.createTable(imageAnnotationStrokes);
      }
      if (from < 8) {
        await customStatement(_createImageAnnotationStrokesIfMissing);
      }
      if (from < 9) {
        await customStatement(_createImageNotesIfMissing);
      }
      if (from < 10) {
        await customStatement(_createGroupAttachmentsIfMissing);
      }
      if (from < 11) {
        await _ensureImageNotePhotoColumn();
      }
      if (from < 12) {
        await _ensureMemorySetGroupStorage();
      }
    },
    beforeOpen: (_) async {
      // Repairs installations that were hot-restarted while the v7 migration
      // was introduced and therefore recorded the version without the table.
      await customStatement(_createImageAnnotationStrokesIfMissing);
      await customStatement(_createImageNotesIfMissing);
      await _ensureImageNotePhotoColumn();
      await customStatement(_createGroupAttachmentsIfMissing);
      await _ensureMemorySetGroupStorage();
    },
  );
}
