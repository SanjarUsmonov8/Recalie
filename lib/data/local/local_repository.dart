import 'dart:convert';
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

  Stream<List<SavedMemorySetGroup>> watchMemorySetGroups() {
    final query = database.select(database.memorySetGroups)
      ..orderBy([
        (row) => OrderingTerm.asc(row.name),
        (row) => OrderingTerm.asc(row.id),
      ]);
    return query.watch().asyncMap((rows) async {
      final sets = await database.select(database.pictureGroups).get();
      return rows
          .map(
            (row) => SavedMemorySetGroup(
              id: row.id,
              name: row.name,
              coverImageBytes: row.coverImageBytes,
              setCount: sets
                  .where((set) => set.memorySetGroupId == row.id)
                  .length,
            ),
          )
          .toList();
    });
  }

  Future<List<SavedMemorySetGroup>> getMemorySetGroups() async {
    final rows =
        await (database.select(database.memorySetGroups)..orderBy([
              (row) => OrderingTerm.asc(row.name),
              (row) => OrderingTerm.asc(row.id),
            ]))
            .get();
    final sets = await database.select(database.pictureGroups).get();
    return rows
        .map(
          (row) => SavedMemorySetGroup(
            id: row.id,
            name: row.name,
            coverImageBytes: row.coverImageBytes,
            setCount: sets
                .where((set) => set.memorySetGroupId == row.id)
                .length,
          ),
        )
        .toList();
  }

  Future<void> updateMemorySetGroup({
    required int groupId,
    required String name,
    Uint8List? coverImageBytes,
    bool replaceCover = false,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('A group needs a name.');
    }
    await (database.update(
      database.memorySetGroups,
    )..where((row) => row.id.equals(groupId))).write(
      MemorySetGroupsCompanion(
        name: Value(trimmedName),
        coverImageBytes: replaceCover
            ? Value(coverImageBytes)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteMemorySetGroup(int groupId) async {
    await database.transaction(() async {
      await (database.update(database.pictureGroups)
            ..where((row) => row.memorySetGroupId.equals(groupId)))
          .write(const PictureGroupsCompanion(memorySetGroupId: Value(null)));
      await (database.delete(
        database.memorySetGroups,
      )..where((row) => row.id.equals(groupId))).go();
    });
  }

  Future<int> pictureGroupCount() async {
    final countExpression = database.pictureGroups.id.count();
    final row = await (database.selectOnly(
      database.pictureGroups,
    )..addColumns([countExpression])).getSingle();
    return row.read(countExpression) ?? 0;
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
    final attachments =
        await (database.select(database.groupAttachments)
              ..where((row) => row.pictureGroupId.equals(group.id))
              ..orderBy([
                (row) => OrderingTerm.asc(row.type),
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
      memorySetGroupId: group.memorySetGroupId,
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
      attachments: attachments
          .map(
            (attachment) => SavedAttachment(
              id: attachment.id,
              pictureGroupId: attachment.pictureGroupId,
              type: attachment.type,
              displayName: attachment.displayName,
              data: attachment.data,
              position: attachment.position,
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
    int? memorySetGroupId,
    String? newMemorySetGroupName,
    Uint8List? newMemorySetGroupCover,
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
      final resolvedMemorySetGroupId = await _resolveMemorySetGroup(
        existingGroupId: memorySetGroupId,
        newGroupName: newMemorySetGroupName,
        newGroupCover: newMemorySetGroupCover,
        now: now,
      );
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
              memorySetGroupId: Value(resolvedMemorySetGroupId),
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

  Stream<List<SavedRecallEvent>> watchAllRecallEvents() {
    final query = database.select(database.recallEvents)
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
    int? memorySetGroupId,
    String? newMemorySetGroupName,
    Uint8List? newMemorySetGroupCover,
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
    await database.transaction(() async {
      final now = DateTime.now();
      final resolvedMemorySetGroupId = await _resolveMemorySetGroup(
        existingGroupId: memorySetGroupId,
        newGroupName: newMemorySetGroupName,
        newGroupCover: newMemorySetGroupCover,
        now: now,
      );
      await (database.update(
        database.pictureGroups,
      )..where((row) => row.id.equals(pictureGroupId))).write(
        PictureGroupsCompanion(
          setNumber: Value(setNumber),
          name: Value(trimmedName),
          planType: Value(planType),
          planStartDate: Value(planStartDate),
          memorySetGroupId: Value(resolvedMemorySetGroupId),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<int?> _resolveMemorySetGroup({
    required int? existingGroupId,
    required String? newGroupName,
    required Uint8List? newGroupCover,
    required DateTime now,
  }) async {
    final trimmedName = newGroupName?.trim() ?? '';
    if (trimmedName.isEmpty) return existingGroupId;
    return database
        .into(database.memorySetGroups)
        .insert(
          MemorySetGroupsCompanion.insert(
            name: trimmedName,
            coverImageBytes: Value(newGroupCover),
            createdAt: now,
            updatedAt: now,
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

  Future<void> addAttachments({
    required int pictureGroupId,
    required String type,
    required List<AttachmentDraft> attachments,
  }) async {
    if (attachments.isEmpty) return;
    await database.transaction(() async {
      final existing =
          await (database.select(database.groupAttachments)..where(
                (row) =>
                    row.pictureGroupId.equals(pictureGroupId) &
                    row.type.equals(type),
              ))
              .get();
      final now = DateTime.now();
      await database.batch((batch) {
        batch.insertAll(
          database.groupAttachments,
          attachments.indexed.map(
            (entry) => GroupAttachmentsCompanion.insert(
              pictureGroupId: pictureGroupId,
              type: type,
              displayName: entry.$2.displayName,
              data: entry.$2.data,
              position: Value(existing.length + entry.$1 + 1),
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

  Future<void> touchPictureGroup(int pictureGroupId) {
    return (database.update(database.pictureGroups)
          ..where((row) => row.id.equals(pictureGroupId)))
        .write(PictureGroupsCompanion(updatedAt: Value(DateTime.now())));
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

  Future<void> moveAttachment({
    required int pictureGroupId,
    required int attachmentId,
    required String type,
    required int newPosition,
  }) async {
    await database.transaction(() async {
      final attachments =
          await (database.select(database.groupAttachments)
                ..where(
                  (row) =>
                      row.pictureGroupId.equals(pictureGroupId) &
                      row.type.equals(type),
                )
                ..orderBy([
                  (row) => OrderingTerm.asc(row.position),
                  (row) => OrderingTerm.asc(row.id),
                ]))
              .get();
      if (attachments.isEmpty) return;
      final oldIndex = attachments.indexWhere(
        (attachment) => attachment.id == attachmentId,
      );
      if (oldIndex < 0) return;
      final targetIndex = (newPosition - 1).clamp(0, attachments.length - 1);
      final reordered = [...attachments];
      final moved = reordered.removeAt(oldIndex);
      reordered.insert(targetIndex, moved);
      for (var index = 0; index < reordered.length; index++) {
        await (database.update(database.groupAttachments)
              ..where((row) => row.id.equals(reordered[index].id)))
            .write(GroupAttachmentsCompanion(position: Value(index + 1)));
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

  Future<void> deletePicture({
    required int pictureGroupId,
    required int pictureId,
  }) async {
    await database.ensureImageNoteStorage();
    await database.transaction(() async {
      await (database.delete(
        database.imageNotes,
      )..where((row) => row.pictureId.equals(pictureId))).go();
      await (database.delete(
        database.imageAnnotationStrokes,
      )..where((row) => row.pictureId.equals(pictureId))).go();
      await (database.delete(
        database.groupPictures,
      )..where((row) => row.id.equals(pictureId))).go();

      final remaining =
          await (database.select(database.groupPictures)
                ..where((row) => row.pictureGroupId.equals(pictureGroupId))
                ..orderBy([
                  (row) => OrderingTerm.asc(row.position),
                  (row) => OrderingTerm.asc(row.id),
                ]))
              .get();
      for (var index = 0; index < remaining.length; index++) {
        await (database.update(database.groupPictures)
              ..where((row) => row.id.equals(remaining[index].id)))
            .write(GroupPicturesCompanion(position: Value(index + 1)));
      }
      await (database.update(database.pictureGroups)
            ..where((row) => row.id.equals(pictureGroupId)))
          .write(PictureGroupsCompanion(updatedAt: Value(DateTime.now())));
    });
  }

  Future<void> deleteMemorySetItems({
    required int pictureGroupId,
    required Set<int> pictureIds,
    required Set<int> attachmentIds,
    required Set<int> textPageIndexes,
  }) async {
    if (pictureIds.isEmpty &&
        attachmentIds.isEmpty &&
        textPageIndexes.isEmpty) {
      return;
    }
    if (pictureIds.isNotEmpty) await database.ensureImageNoteStorage();
    await database.transaction(() async {
      for (final pictureId in pictureIds) {
        await (database.delete(
          database.imageNotes,
        )..where((row) => row.pictureId.equals(pictureId))).go();
        await (database.delete(
          database.imageAnnotationStrokes,
        )..where((row) => row.pictureId.equals(pictureId))).go();
        await (database.delete(
          database.groupPictures,
        )..where((row) => row.id.equals(pictureId))).go();
      }
      for (final attachmentId in attachmentIds) {
        await (database.delete(
          database.groupAttachments,
        )..where((row) => row.id.equals(attachmentId))).go();
      }

      if (textPageIndexes.isNotEmpty) {
        final group = await (database.select(
          database.pictureGroups,
        )..where((row) => row.id.equals(pictureGroupId))).getSingleOrNull();
        if (group != null) {
          final pages = group.textContent?.split('\f') ?? const <String>[];
          final remainingPages = [
            for (var index = 0; index < pages.length; index++)
              if (!textPageIndexes.contains(index)) pages[index],
          ];
          await (database.update(
            database.pictureGroups,
          )..where((row) => row.id.equals(pictureGroupId))).write(
            PictureGroupsCompanion(
              textContent: Value(
                remainingPages.isEmpty ? null : remainingPages.join('\f'),
              ),
            ),
          );
        }
      }

      final remainingPictures =
          await (database.select(database.groupPictures)
                ..where((row) => row.pictureGroupId.equals(pictureGroupId))
                ..orderBy([
                  (row) => OrderingTerm.asc(row.position),
                  (row) => OrderingTerm.asc(row.id),
                ]))
              .get();
      for (var index = 0; index < remainingPictures.length; index++) {
        await (database.update(database.groupPictures)
              ..where((row) => row.id.equals(remainingPictures[index].id)))
            .write(GroupPicturesCompanion(position: Value(index + 1)));
      }

      for (final type in const ['file', 'audio', 'video']) {
        final remainingAttachments =
            await (database.select(database.groupAttachments)
                  ..where(
                    (row) =>
                        row.pictureGroupId.equals(pictureGroupId) &
                        row.type.equals(type),
                  )
                  ..orderBy([
                    (row) => OrderingTerm.asc(row.position),
                    (row) => OrderingTerm.asc(row.id),
                  ]))
                .get();
        for (var index = 0; index < remainingAttachments.length; index++) {
          await (database.update(database.groupAttachments)
                ..where((row) => row.id.equals(remainingAttachments[index].id)))
              .write(GroupAttachmentsCompanion(position: Value(index + 1)));
        }
      }

      await (database.update(database.pictureGroups)
            ..where((row) => row.id.equals(pictureGroupId)))
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
            images: _decodeNoteImages(row.imageBytes),
          ),
        )
        .toList();
  }

  Future<SavedImageNote> createImageNote({
    required int pictureId,
    required double normalizedX,
    required double normalizedY,
    required String content,
    List<Uint8List> images = const [],
  }) async {
    await database.ensureImageNoteStorage();
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty && images.isEmpty) {
      throw ArgumentError('A note needs text or a photo.');
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
            imageBytes: Value(_encodeNoteImages(images)),
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
      images: List<Uint8List>.unmodifiable(images),
    );
  }

  Future<void> updateImageNote(
    int noteId,
    String content, {
    List<Uint8List> images = const [],
  }) async {
    await database.ensureImageNoteStorage();
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty && images.isEmpty) {
      throw ArgumentError('A note needs text or a photo.');
    }
    await (database.update(
      database.imageNotes,
    )..where((row) => row.id.equals(noteId))).write(
      ImageNotesCompanion(
        content: Value(trimmedContent),
        imageBytes: Value(_encodeNoteImages(images)),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateImageNotePosition({
    required int noteId,
    required double normalizedX,
    required double normalizedY,
  }) async {
    await database.ensureImageNoteStorage();
    await (database.update(
      database.imageNotes,
    )..where((row) => row.id.equals(noteId))).write(
      ImageNotesCompanion(
        normalizedX: Value(normalizedX.clamp(0.0, 1.0)),
        normalizedY: Value(normalizedY.clamp(0.0, 1.0)),
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
        database.groupAttachments,
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
    this.memorySetGroupId,
    required this.pictures,
    required this.attachments,
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
  final int? memorySetGroupId;
  final List<SavedPicture> pictures;
  final List<SavedAttachment> attachments;

  List<Uint8List> get images =>
      pictures.map((picture) => picture.bytes).toList();
}

class SavedMemorySetGroup {
  const SavedMemorySetGroup({
    required this.id,
    required this.name,
    required this.coverImageBytes,
    required this.setCount,
  });

  final int id;
  final String name;
  final Uint8List? coverImageBytes;
  final int setCount;
}

class AttachmentDraft {
  const AttachmentDraft({required this.displayName, required this.data});

  final String displayName;
  final Uint8List data;
}

class SavedAttachment {
  const SavedAttachment({
    required this.id,
    required this.pictureGroupId,
    required this.type,
    required this.displayName,
    required this.data,
    required this.position,
  });

  final int id;
  final int pictureGroupId;
  final String type;
  final String displayName;
  final Uint8List data;
  final int position;
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
    required this.images,
  });

  final int id;
  final int pictureId;
  final double normalizedX;
  final double normalizedY;
  final String content;
  final List<Uint8List> images;

  SavedImageNote copyWith({
    double? normalizedX,
    double? normalizedY,
    String? content,
    List<Uint8List>? images,
  }) {
    return SavedImageNote(
      id: id,
      pictureId: pictureId,
      normalizedX: normalizedX ?? this.normalizedX,
      normalizedY: normalizedY ?? this.normalizedY,
      content: content ?? this.content,
      images: images ?? this.images,
    );
  }
}

const _noteImagesPrefix = 'RECALIE_NOTE_IMAGES_V1\n';

Uint8List? _encodeNoteImages(List<Uint8List> images) {
  if (images.isEmpty) return null;
  final payload = jsonEncode(images.map(base64Encode).toList());
  return Uint8List.fromList(utf8.encode('$_noteImagesPrefix$payload'));
}

List<Uint8List> _decodeNoteImages(Uint8List? stored) {
  if (stored == null || stored.isEmpty) return const [];
  final prefix = utf8.encode(_noteImagesPrefix);
  if (stored.length < prefix.length) return [stored];
  for (var index = 0; index < prefix.length; index++) {
    if (stored[index] != prefix[index]) return [stored];
  }
  try {
    final payload = utf8.decode(stored.sublist(prefix.length));
    final encodedImages = (jsonDecode(payload) as List<dynamic>).cast<String>();
    return encodedImages.map(base64Decode).toList(growable: false);
  } on Object {
    return [stored];
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
