import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class AppPreferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class PictureGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get textContent => text().nullable()();
  TextColumn get planType =>
      text().withDefault(const Constant('most_effective'))();
  DateTimeColumn get planStartDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class GroupPictures extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pictureGroupId => integer().references(PictureGroups, #id)();
  BlobColumn get imageBytes => blob()();
  DateTimeColumn get createdAt => dateTime()();
}

class RecallEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pictureGroupId => integer().references(PictureGroups, #id)();
  DateTimeColumn get recalledAt => dateTime()();
}

@DriftDatabase(
  tables: [AppPreferences, PictureGroups, GroupPictures, RecallEvents],
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

  @override
  int get schemaVersion => 4;

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
    },
  );
}
