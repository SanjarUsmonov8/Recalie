import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recalie/data/local/app_database.dart';
import 'package:recalie/data/local/local_repository.dart';
import 'package:recalie/features/recall_plan/recall_review_completion.dart';

void main() {
  test(
    'memory sets, edits, pictures, recalls, and deletion persist offline',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'recalie_storage_',
      );
      final file = File('${directory.path}/recalie.sqlite');
      addTearDown(() => directory.delete(recursive: true));

      var database = AppDatabase(NativeDatabase(file));
      var repository = LocalRepository(database);

      // Reproduce the broken v7 state seen after a hot restart: the database
      // version exists, but its annotation table does not.
      await database.customStatement('DROP TABLE image_annotation_strokes');
      await database.customStatement('DROP TABLE image_notes');
      await database.customStatement('PRAGMA user_version = 7');
      await database.close();
      database = AppDatabase(NativeDatabase(file));
      repository = LocalRepository(database);

      await repository.savePreference('theme_mode', 'dark');
      await repository.createPictureGroup(
        name: 'First week',
        images: [
          Uint8List.fromList([1, 2, 3, 4]),
        ],
        textContent: 'Information to remember',
        planStartDate: DateTime(2026, 10, 4),
        coverIcon: 'science',
        coverColorStart: '#2563EB',
        coverColorEnd: '#7C3AED',
        coverImageUrl: 'https://example.com/cover.png',
      );
      await repository.recordRecall(1, DateTime(2026, 10, 4, 9));
      await database.close();

      database = AppDatabase(NativeDatabase(file));
      repository = LocalRepository(database);

      expect(await repository.readPreference('theme_mode'), 'dark');
      final pictureGroups = await repository.watchPictureGroups().first;
      expect(pictureGroups, hasLength(1));
      expect(pictureGroups.single.name, 'First week');
      expect(pictureGroups.single.textContent, 'Information to remember');
      expect(pictureGroups.single.planType, 'most_effective');
      expect(pictureGroups.single.planStartDate, DateTime(2026, 10, 4));
      expect(pictureGroups.single.coverIcon, 'science');
      expect(pictureGroups.single.coverColorStart, '#2563EB');
      expect(pictureGroups.single.coverColorEnd, '#7C3AED');
      expect(
        pictureGroups.single.coverImageUrl,
        'https://example.com/cover.png',
      );
      expect(pictureGroups.single.images.single, [1, 2, 3, 4]);
      expect(await repository.watchRecallEvents(1).first, hasLength(1));

      await repository.renameSubject(1, 'Biology chapter');
      await repository.updateSubjectText(1, 'Updated information');
      await repository.addSubjectPictures(1, [
        Uint8List.fromList([5, 6, 7, 8]),
      ]);
      await repository.createPictureGroup(
        name: 'Temporary memory set',
        images: const [],
        planStartDate: DateTime(2027, 1, 12),
        planType: 'effective',
      );
      await repository.deleteSubject(2);

      await database.close();
      database = AppDatabase(NativeDatabase(file));
      repository = LocalRepository(database);

      final updatedSubject = await repository.watchPictureGroup(1).first;
      expect(updatedSubject?.name, 'Biology chapter');
      expect(updatedSubject?.textContent, 'Updated information');
      expect(updatedSubject?.images, hasLength(2));
      expect(await repository.watchPictureGroups().first, hasLength(1));

      final pictureId = updatedSubject!.pictures.first.id;
      await repository.replaceImageAnnotations(
        pictureId: pictureId,
        annotations: const [
          ImageAnnotationDraft(
            tool: 'pen',
            isStraight: false,
            thickness: 5,
            opacity: 0.9,
            colorValue: 0xFFFF0000,
            normalizedPoints: [0.1, 0.2, 0.7, 0.8],
          ),
        ],
      );

      await database.close();
      database = AppDatabase(NativeDatabase(file));
      repository = LocalRepository(database);

      var savedAnnotations = await repository.loadImageAnnotations(pictureId);
      expect(savedAnnotations, hasLength(1));
      expect(savedAnnotations.single.tool, 'pen');
      expect(savedAnnotations.single.normalizedPoints, [0.1, 0.2, 0.7, 0.8]);

      await repository.replaceImageAnnotations(
        pictureId: pictureId,
        annotations: const [
          ImageAnnotationDraft(
            tool: 'highlighter',
            isStraight: true,
            thickness: 14,
            opacity: 0.35,
            colorValue: 0xFFFFFF00,
            normalizedPoints: [0.2, 0.3, 0.8, 0.3],
          ),
        ],
      );
      savedAnnotations = await repository.loadImageAnnotations(pictureId);
      expect(savedAnnotations, hasLength(1));
      expect(savedAnnotations.single.tool, 'highlighter');
      expect(savedAnnotations.single.opacity, 0.35);

      // A currently-open database can also be missing the new table after a
      // hot reload. Repository operations must repair it immediately.
      await database.customStatement('DROP TABLE image_notes');
      final firstNote = await repository.createImageNote(
        pictureId: pictureId,
        normalizedX: 0.25,
        normalizedY: 0.4,
        content: 'Remember this formula',
      );
      await repository.createImageNote(
        pictureId: pictureId,
        normalizedX: 0.75,
        normalizedY: 0.65,
        content: 'Second note',
      );

      await database.close();
      database = AppDatabase(NativeDatabase(file));
      repository = LocalRepository(database);

      var savedNotes = await repository.loadImageNotes(pictureId);
      expect(savedNotes, hasLength(2));
      expect(savedNotes.first.content, 'Remember this formula');
      await repository.updateImageNote(firstNote.id, 'Updated note');
      await repository.deleteImageNote(savedNotes.last.id);
      savedNotes = await repository.loadImageNotes(pictureId);
      expect(savedNotes, hasLength(1));
      expect(savedNotes.single.content, 'Updated note');

      await repository.deleteSubject(1);
      expect(await repository.watchPictureGroups().first, isEmpty);
      expect(await repository.watchRecallEvents(1).first, isEmpty);

      await database.close();
    },
  );

  test('reviewing every image and text page completes today', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final repository = LocalRepository(database);
    addTearDown(database.close);
    final now = DateTime.now();
    await repository.createPictureGroup(
      name: 'Complete set',
      images: [
        Uint8List.fromList([1, 2, 3]),
      ],
      textContent: 'First page\fSecond page',
      planStartDate: DateTime(now.year, now.month, now.day),
    );
    final subject = await repository.getPictureGroup(1);
    await repository.setPictureReviewed(subject!.pictures.single.id, true);
    await repository.savePreference('subject_text_reviewed_1', '0,1');

    expect(
      await completeTodayIfEveryItemIsReviewed(
        repository: repository,
        subjectId: 1,
      ),
      isTrue,
    );
    expect(await repository.watchRecallEvents(1).first, hasLength(2));
  });
}
