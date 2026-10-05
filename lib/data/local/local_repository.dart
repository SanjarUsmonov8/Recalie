import 'package:drift/drift.dart';

import 'app_database.dart';

class LocalRepository {
  const LocalRepository(this.database);

  final AppDatabase database;

  Stream<List<SavedPictureGroup>> watchPictureGroups() {
    final groups = database.select(database.pictureGroups)
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);
    return groups.watch().asyncMap((savedGroups) async {
      return Future.wait(savedGroups.map(_hydratePictureGroup));
    });
  }

  Stream<SavedPictureGroup?> watchPictureGroup(int pictureGroupId) {
    final query = database.select(database.pictureGroups)
      ..where((row) => row.id.equals(pictureGroupId));
    return query.watchSingleOrNull().asyncMap(
      (group) => group == null ? null : _hydratePictureGroup(group),
    );
  }

  Future<SavedPictureGroup> _hydratePictureGroup(PictureGroup group) async {
    final pictures =
        await (database.select(database.groupPictures)
              ..where((row) => row.pictureGroupId.equals(group.id))
              ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
            .get();
    return SavedPictureGroup(
      id: group.id,
      name: group.name,
      textContent: group.textContent,
      planType: group.planType,
      planStartDate: group.planStartDate ?? group.createdAt,
      images: pictures.map((picture) => picture.imageBytes).toList(),
    );
  }

  Future<void> createPictureGroup({
    required String name,
    required List<Uint8List> images,
    String? textContent,
    DateTime? planStartDate,
    String planType = 'most_effective',
  }) async {
    final trimmedName = name.trim();
    final trimmedText = textContent?.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('A memory set needs a name.');
    }

    await database.transaction(() async {
      final now = DateTime.now();
      final groupId = await database
          .into(database.pictureGroups)
          .insert(
            PictureGroupsCompanion.insert(
              name: trimmedName,
              textContent: Value(
                (trimmedText?.isEmpty ?? true) ? null : trimmedText,
              ),
              planStartDate: Value(planStartDate ?? now),
              planType: Value(planType),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await database.batch((batch) {
        batch.insertAll(
          database.groupPictures,
          images.map(
            (image) => GroupPicturesCompanion.insert(
              pictureGroupId: groupId,
              imageBytes: image,
              createdAt: now,
            ),
          ),
        );
      });
    });
  }

  Stream<List<SavedRecallEvent>> watchRecallEvents(int pictureGroupId) {
    final query = database.select(database.recallEvents)
      ..where((row) => row.pictureGroupId.equals(pictureGroupId))
      ..orderBy([(row) => OrderingTerm.asc(row.recalledAt)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => SavedRecallEvent(
              id: row.id,
              pictureGroupId: row.pictureGroupId,
              recalledAt: row.recalledAt,
            ),
          )
          .toList(),
    );
  }

  Future<int> recordRecall(int pictureGroupId, DateTime recalledAt) {
    return database
        .into(database.recallEvents)
        .insert(
          RecallEventsCompanion.insert(
            pictureGroupId: pictureGroupId,
            recalledAt: recalledAt,
          ),
        );
  }

  Future<void> renameSubject(int pictureGroupId, String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('The memory set needs a name.');
    }
    await (database.update(
      database.pictureGroups,
    )..where((row) => row.id.equals(pictureGroupId))).write(
      PictureGroupsCompanion(
        name: Value(trimmedName),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateMemorySetPlan({
    required int pictureGroupId,
    required String name,
    required String planType,
    required DateTime planStartDate,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('The memory set needs a name.');
    }
    await (database.update(
      database.pictureGroups,
    )..where((row) => row.id.equals(pictureGroupId))).write(
      PictureGroupsCompanion(
        name: Value(trimmedName),
        planType: Value(planType),
        planStartDate: Value(planStartDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateSubjectText(int pictureGroupId, String text) async {
    final trimmedText = text.trim();
    await (database.update(
      database.pictureGroups,
    )..where((row) => row.id.equals(pictureGroupId))).write(
      PictureGroupsCompanion(
        textContent: Value(trimmedText.isEmpty ? null : trimmedText),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> addSubjectPictures(
    int pictureGroupId,
    List<Uint8List> images,
  ) async {
    if (images.isEmpty) return;
    await database.transaction(() async {
      final now = DateTime.now();
      await database.batch((batch) {
        batch.insertAll(
          database.groupPictures,
          images.map(
            (image) => GroupPicturesCompanion.insert(
              pictureGroupId: pictureGroupId,
              imageBytes: image,
              createdAt: now,
            ),
          ),
        );
      });
      await (database.update(database.pictureGroups)
            ..where((row) => row.id.equals(pictureGroupId)))
          .write(PictureGroupsCompanion(updatedAt: Value(now)));
    });
  }

  Future<void> deleteSubject(int pictureGroupId) async {
    await database.transaction(() async {
      await (database.delete(
        database.recallEvents,
      )..where((row) => row.pictureGroupId.equals(pictureGroupId))).go();
      await (database.delete(
        database.groupPictures,
      )..where((row) => row.pictureGroupId.equals(pictureGroupId))).go();
      await (database.delete(
        database.pictureGroups,
      )..where((row) => row.id.equals(pictureGroupId))).go();
    });
  }

  Future<String?> readPreference(String key) async {
    final query = database.select(database.appPreferences)
      ..where((row) => row.key.equals(key));
    return (await query.getSingleOrNull())?.value;
  }

  Future<void> savePreference(String key, String value) {
    return database
        .into(database.appPreferences)
        .insertOnConflictUpdate(
          AppPreferencesCompanion.insert(
            key: key,
            value: value,
            updatedAt: DateTime.now(),
          ),
        );
  }
}

class SavedPictureGroup {
  const SavedPictureGroup({
    required this.id,
    required this.name,
    required this.textContent,
    required this.planType,
    required this.planStartDate,
    required this.images,
  });

  final int id;
  final String name;
  final String? textContent;
  final String planType;
  final DateTime planStartDate;
  final List<Uint8List> images;
}

class SavedRecallEvent {
  const SavedRecallEvent({
    required this.id,
    required this.pictureGroupId,
    required this.recalledAt,
  });

  final int id;
  final int pictureGroupId;
  final DateTime recalledAt;
}
