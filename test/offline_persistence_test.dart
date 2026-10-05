import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recalie/data/local/app_database.dart';
import 'package:recalie/data/local/local_repository.dart';

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

      await repository.savePreference('theme_mode', 'dark');
      await repository.createPictureGroup(
        name: 'First week',
        images: [
          Uint8List.fromList([1, 2, 3, 4]),
        ],
        textContent: 'Information to remember',
        planStartDate: DateTime(2026, 10, 4),
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

      await repository.deleteSubject(1);
      expect(await repository.watchPictureGroups().first, isEmpty);
      expect(await repository.watchRecallEvents(1).first, isEmpty);

      await database.close();
    },
  );
}
