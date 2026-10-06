import 'dart:typed_data';

import 'package:drift/drift.dart';

import 'app_database.dart';

class LocalRepository {
  const LocalRepository(this.database);

  final AppDatabase database;

  Stream<List<SavedPictureGroup>> watchPictureGroups() {
    final groups = database.select(database.pictureGroups)
      ..orderBy([
        (row) => OrderingTerm.asc(row.setNumber),
        (row) => OrderingTerm.asc(row.id),
      ]);
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

  Future<SavedPictureGroup?> getPictureGroup(int pictureGroupId) async {
    final query = database.select(database.pictureGroups)
      ..where((row) => row.id.equals(pictureGroupId));
    final group = await query.getSingleOrNull();
    return group == null ? null : _hydratePictureGroup(group);
  }

  Future<SavedPictureGroup> _hydratePictureGroup(PictureGroup group) async {
    final pictures =
        await (database.select(database.groupPictures)
              ..where((row) => row.pictureGroupId.equals(group.id))
              ..orderBy([
                (row) => OrderingTerm.asc(row.position),
                (row) => OrderingTerm.asc(row.id),
              ]))
            .get();
    return SavedPictureGroup(
      id: group.id,
      setNumber: group.setNumber ?? group.id,
      name: group.name,
      textContent: group.textContent,
      planType: group.planType,
      planStartDate: group.planStartDate ?? group.createdAt,
      coverIcon: group.coverIcon,
      coverColorStart: group.coverColorStart,
      coverColorEnd: group.coverColorEnd,
      coverImageUrl: group.coverImageUrl,
      pictures: pictures
          .map(
            (picture) => SavedPicture(
              id: picture.id,
              bytes: picture.imageBytes,
              position: picture.position,
              isReviewed: picture.isReviewed,
            ),
          )
          .toList(),
    );
  }

  Future<int> nextSetNumber() async {
    final numbers = database.selectOnly(database.pictureGroups)
      ..addColumns([database.pictureGroups.setNumber.max()]);
    final row = await numbers.getSingle();
    return (row.read(database.pictureGroups.setNumber.max()) ?? 0) + 1;
  }

  Future<bool> isSetNumberAvailable(int setNumber, {int? exceptGroupId}) async {
    final query = database.select(database.pictureGroups)
      ..where((row) => row.setNumber.equals(setNumber));
    if (exceptGroupId != null) {
      query.where((row) => row.id.equals(exceptGroupId).not());
    }
    return await query.getSingleOrNull() == null;
  }

  Future<void> createPictureGroup({
    required String name,
    required List<Uint8List> images,
    int? setNumber,
    String? textContent,
    DateTime? planStartDate,
    String planType = 'most_effective',
    String? coverIcon,
    String? coverColorStart,
    String? coverColorEnd,
    String? coverImageUrl,
  }) async {
    final trimmedName = name.trim();
    final trimmedText = textContent?.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('A memory set needs a name.');
    }

    await database.transaction(() async {
      final resolvedSetNumber = setNumber ?? await nextSetNumber();
      if (resolvedSetNumber < 1) {
        throw ArgumentError('The memory set number must be at least 1.');
      }
      if (!await isSetNumberAvailable(resolvedSetNumber)) {
        throw SetNumberAlreadyUsedException(resolvedSetNumber);
      }
      final now = DateTime.now();
      final groupId = await database
          .into(database.pictureGroups)
          .insert(
            PictureGroupsCompanion.insert(
              setNumber: Value(resolvedSetNumber),
              name: trimmedName,
              textContent: Value(
                (trimmedText?.isEmpty ?? true) ? null : trimmedText,
              ),
              planStartDate: Value(planStartDate ?? now),
              planType: Value(planType),
              coverIcon: Value(coverIcon),
              coverColorStart: Value(coverColorStart),
              coverColorEnd: Value(coverColorEnd),
              coverImageUrl: Value(coverImageUrl),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await database.batch((batch) {
        batch.insertAll(
          database.groupPictures,
          images.indexed.map(
            (entry) => GroupPicturesCompanion.insert(
              pictureGroupId: groupId,
              imageBytes: entry.$2,
              position: Value(entry.$1 + 1),
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
    required int setNumber,
    required String name,
    required String planType,
    required DateTime planStartDate,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('The memory set needs a name.');
    }
    if (setNumber < 1) {
      throw ArgumentError('The memory set number must be at least 1.');
    }
    if (!await isSetNumberAvailable(setNumber, exceptGroupId: pictureGroupId)) {
      throw SetNumberAlreadyUsedException(setNumber);
    }
    await (database.update(
      database.pictureGroups,
    )..where((row) => row.id.equals(pictureGroupId))).write(
      PictureGroupsCompanion(
        setNumber: Value(setNumber),
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
      final existingPictures = await (database.select(
        database.groupPictures,
      )..where((row) => row.pictureGroupId.equals(pictureGroupId))).get();
      final firstPosition = existingPictures.length + 1;
      await database.batch((batch) {
        batch.insertAll(
          database.groupPictures,
          images.indexed.map(
            (entry) => GroupPicturesCompanion.insert(
              pictureGroupId: pictureGroupId,
              imageBytes: entry.$2,
              position: Value(firstPosition + entry.$1),
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

  Future<void> movePicture({
    required int pictureGroupId,
    required int pictureId,
    required int newPosition,
  }) async {
    await database.transaction(() async {
      final pictures =
          await (database.select(database.groupPictures)
                ..where((row) => row.pictureGroupId.equals(pictureGroupId))
                ..orderBy([
                  (row) => OrderingTerm.asc(row.position),
                  (row) => OrderingTerm.asc(row.id),
                ]))
              .get();
      if (pictures.isEmpty) return;
      final oldIndex = pictures.indexWhere(
        (picture) => picture.id == pictureId,
      );
      if (oldIndex < 0) return;
      final targetIndex = (newPosition - 1).clamp(0, pictures.length - 1);
      final reordered = [...pictures];
      final moved = reordered.removeAt(oldIndex);
      reordered.insert(targetIndex, moved);
      for (var index = 0; index < reordered.length; index++) {
        await (database.update(database.groupPictures)
              ..where((row) => row.id.equals(reordered[index].id)))
            .write(GroupPicturesCompanion(position: Value(index + 1)));
      }
      await (database.update(database.pictureGroups)
            ..where((row) => row.id.equals(pictureGroupId)))
          .write(PictureGroupsCompanion(updatedAt: Value(DateTime.now())));
    });
  }

  Future<void> setPictureReviewed(int pictureId, bool isReviewed) async {
    await database.transaction(() async {
      final picture = await (database.select(
        database.groupPictures,
      )..where((row) => row.id.equals(pictureId))).getSingleOrNull();
      if (picture == null) return;
      await (database.update(database.groupPictures)
            ..where((row) => row.id.equals(pictureId)))
          .write(GroupPicturesCompanion(isReviewed: Value(isReviewed)));
      await (database.update(database.pictureGroups)
            ..where((row) => row.id.equals(picture.pictureGroupId)))
          .write(PictureGroupsCompanion(updatedAt: Value(DateTime.now())));
    });
  }

  Future<List<SavedImageAnnotation>> loadImageAnnotations(int pictureId) async {
    final rows =
        await (database.select(database.imageAnnotationStrokes)
              ..where((row) => row.pictureId.equals(pictureId))
              ..orderBy([(row) => OrderingTerm.asc(row.id)]))
            .get();
    return rows
        .map(
          (row) => SavedImageAnnotation(
            id: row.id,
            pictureId: row.pictureId,
            tool: row.tool,
            isStraight: row.isStraight,
            thickness: row.thickness,
            opacity: row.opacity,
            colorValue: row.colorValue,
            normalizedPoints: _decodeAnnotationPoints(row.normalizedPoints),
          ),
        )
        .toList();
  }

  Future<int> addImageAnnotation({
    required int pictureId,
    required String tool,
    required bool isStraight,
    required double thickness,
    required double opacity,
    required int colorValue,
    required List<double> normalizedPoints,
  }) {
    return database
        .into(database.imageAnnotationStrokes)
        .insert(
          ImageAnnotationStrokesCompanion.insert(
            pictureId: pictureId,
            tool: tool,
            isStraight: isStraight,
            thickness: thickness,
            opacity: opacity,
            colorValue: colorValue,
            normalizedPoints: _encodeAnnotationPoints(normalizedPoints),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> deleteImageAnnotation(int annotationId) {
    return (database.delete(
      database.imageAnnotationStrokes,
    )..where((row) => row.id.equals(annotationId))).go();
  }

  Future<void> replaceImageAnnotations({
    required int pictureId,
    required List<ImageAnnotationDraft> annotations,
  }) async {
    await database.transaction(() async {
      await (database.delete(
        database.imageAnnotationStrokes,
      )..where((row) => row.pictureId.equals(pictureId))).go();
      if (annotations.isEmpty) return;
      final now = DateTime.now();
      await database.batch((batch) {
        batch.insertAll(
          database.imageAnnotationStrokes,
          annotations.map(
            (annotation) => ImageAnnotationStrokesCompanion.insert(
              pictureId: pictureId,
              tool: annotation.tool,
              isStraight: annotation.isStraight,
              thickness: annotation.thickness,
              opacity: annotation.opacity,
              colorValue: annotation.colorValue,
              normalizedPoints: _encodeAnnotationPoints(
                annotation.normalizedPoints,
              ),
              createdAt: now,
            ),
          ),
        );
      });
    });
  }

  Future<List<SavedImageNote>> loadImageNotes(int pictureId) async {
    await database.ensureImageNoteStorage();
    final rows =
        await (database.select(database.imageNotes)
              ..where((row) => row.pictureId.equals(pictureId))
              ..orderBy([(row) => OrderingTerm.asc(row.id)]))
            .get();
    return rows
        .map(
          (row) => SavedImageNote(
            id: row.id,
            pictureId: row.pictureId,
            normalizedX: row.normalizedX,
            normalizedY: row.normalizedY,
            content: row.content,
          ),
        )
        .toList();
  }

  Future<SavedImageNote> createImageNote({
    required int pictureId,
    required double normalizedX,
    required double normalizedY,
    required String content,
  }) async {
    await database.ensureImageNoteStorage();
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      throw ArgumentError('A note cannot be empty.');
    }
    final now = DateTime.now();
    final clampedX = normalizedX.clamp(0.0, 1.0);
    final clampedY = normalizedY.clamp(0.0, 1.0);
    final id = await database
        .into(database.imageNotes)
        .insert(
          ImageNotesCompanion.insert(
            pictureId: pictureId,
            normalizedX: clampedX,
            normalizedY: clampedY,
            content: trimmedContent,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return SavedImageNote(
      id: id,
      pictureId: pictureId,
      normalizedX: clampedX,
      normalizedY: clampedY,
      content: trimmedContent,
    );
  }

  Future<void> updateImageNote(int noteId, String content) async {
    await database.ensureImageNoteStorage();
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      throw ArgumentError('A note cannot be empty.');
    }
    await (database.update(
      database.imageNotes,
    )..where((row) => row.id.equals(noteId))).write(
      ImageNotesCompanion(
        content: Value(trimmedContent),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteImageNote(int noteId) async {
    await database.ensureImageNoteStorage();
    await (database.delete(
      database.imageNotes,
    )..where((row) => row.id.equals(noteId))).go();
  }

  Future<void> deleteSubject(int pictureGroupId) async {
    await database.ensureImageNoteStorage();
    await database.transaction(() async {
      final pictureIds =
          await (database.selectOnly(database.groupPictures)
                ..addColumns([database.groupPictures.id])
                ..where(
                  database.groupPictures.pictureGroupId.equals(pictureGroupId),
                ))
              .map((row) => row.read(database.groupPictures.id)!)
              .get();
      if (pictureIds.isNotEmpty) {
        await (database.delete(
          database.imageNotes,
        )..where((row) => row.pictureId.isIn(pictureIds))).go();
        await (database.delete(
          database.imageAnnotationStrokes,
        )..where((row) => row.pictureId.isIn(pictureIds))).go();
      }
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

Uint8List _encodeAnnotationPoints(List<double> points) {
  final data = ByteData(points.length * 8);
  for (var index = 0; index < points.length; index++) {
    data.setFloat64(index * 8, points[index], Endian.little);
  }
  return data.buffer.asUint8List();
}

List<double> _decodeAnnotationPoints(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  return List<double>.generate(
    bytes.length ~/ 8,
    (index) => data.getFloat64(index * 8, Endian.little),
  );
}

class SavedPictureGroup {
  const SavedPictureGroup({
    required this.id,
    required this.setNumber,
    required this.name,
    required this.textContent,
    required this.planType,
    required this.planStartDate,
    required this.coverIcon,
    required this.coverColorStart,
    required this.coverColorEnd,
    required this.coverImageUrl,
    required this.pictures,
  });

  final int id;
  final int setNumber;
  final String name;
  final String? textContent;
  final String planType;
  final DateTime planStartDate;
  final String? coverIcon;
  final String? coverColorStart;
  final String? coverColorEnd;
  final String? coverImageUrl;
  final List<SavedPicture> pictures;

  List<Uint8List> get images =>
      pictures.map((picture) => picture.bytes).toList();
}

class SavedPicture {
  const SavedPicture({
    required this.id,
    required this.bytes,
    required this.position,
    required this.isReviewed,
  });

  final int id;
  final Uint8List bytes;
  final int position;
  final bool isReviewed;
}

class SavedImageAnnotation {
  const SavedImageAnnotation({
    required this.id,
    required this.pictureId,
    required this.tool,
    required this.isStraight,
    required this.thickness,
    required this.opacity,
    required this.colorValue,
    required this.normalizedPoints,
  });

  final int id;
  final int pictureId;
  final String tool;
  final bool isStraight;
  final double thickness;
  final double opacity;
  final int colorValue;
  final List<double> normalizedPoints;
}

class ImageAnnotationDraft {
  const ImageAnnotationDraft({
    required this.tool,
    required this.isStraight,
    required this.thickness,
    required this.opacity,
    required this.colorValue,
    required this.normalizedPoints,
  });

  final String tool;
  final bool isStraight;
  final double thickness;
  final double opacity;
  final int colorValue;
  final List<double> normalizedPoints;
}

class SavedImageNote {
  const SavedImageNote({
    required this.id,
    required this.pictureId,
    required this.normalizedX,
    required this.normalizedY,
    required this.content,
  });

  final int id;
  final int pictureId;
  final double normalizedX;
  final double normalizedY;
  final String content;

  SavedImageNote copyWith({String? content}) {
    return SavedImageNote(
      id: id,
      pictureId: pictureId,
      normalizedX: normalizedX,
      normalizedY: normalizedY,
      content: content ?? this.content,
    );
  }
}

class SetNumberAlreadyUsedException implements Exception {
  const SetNumberAlreadyUsedException(this.setNumber);

  final int setNumber;
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
