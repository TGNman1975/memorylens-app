import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_lens/database/app_database.dart';

void main() {
  test(
    'fresh database supports folder lifecycle and never reseeds deleted defaults',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'memorylens-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/test.sqlite');
      final db = AppDatabase.forTesting(NativeDatabase(file));
      expect(
        (await db.getFolders()).map((folder) => folder.name),
        unorderedEquals([
          'Home',
          'Family & Friends',
          'Health',
          'Travel',
          'Work',
          'Shopping',
          'Important',
          'Ideas',
        ]),
      );
      final home = (await db.getFolders()).firstWhere(
        (folder) => folder.name == 'Home',
      );
      await expectLater(db.saveFolder('  '), throwsArgumentError);
      await expectLater(db.saveFolder(' home '), throwsArgumentError);
      await expectLater(db.saveFolder(' Unfiled '), throwsArgumentError);

      final id = await db.saveFolder('  Projects ');
      await db.saveFolder('New Projects', id: id);
      expect(
        (await db.getFolders()).singleWhere((folder) => folder.id == id).name,
        'New Projects',
      );
      final memoryId = await db.addMemory(
        MemoriesCompanion.insert(title: 'Keep this', folderId: Value(home.id)),
      );
      final memory = (await db.getMemory(memoryId))!;
      await db.updateMemory(memory.copyWith(folderId: Value(id)));
      expect((await db.getMemory(memoryId))!.folderId, id);
      await db.updateMemory(memory.copyWith(folderId: const Value(null)));
      expect((await db.getMemory(memoryId))!.folderId, isNull);
      await db.updateMemory(memory.copyWith(folderId: Value(id)));
      await db.deleteFolder(id);
      expect((await db.getMemory(memoryId))!.folderId, isNull);
      await db.deleteFolder(home.id);
      await db.close();

      final reopened = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(reopened.close);
      expect(await reopened.getFolders(), hasLength(7));
      expect((await reopened.getMemory(memoryId))!.title, 'Keep this');
    },
  );

  for (final version in [1, 2]) {
    test(
      'upgrades schema v$version in place and preserves existing fields',
      () async {
        final db = AppDatabase.forTesting(
          NativeDatabase.memory(
            setup: (raw) {
              raw.execute('''
          CREATE TABLE memories (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            note TEXT,
            image_path TEXT,
            latitude REAL,
            longitude REAL,
            favourite INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP)),
            updated_at INTEGER
            ${version == 2 ? ', reminder_at INTEGER' : ''}
          );
          INSERT INTO memories VALUES (
            42, 'Old title', 'Old note', '/photos/original.jpg',
            12.5, 20.5, 1, 1700000000, 1700000010
            ${version == 2 ? ', 1800000000' : ''}
          );
          PRAGMA user_version = $version;
        ''');
            },
          ),
        );
        addTearDown(db.close);
        final memory = (await db.getAllMemories()).single;
        expect(memory.id, 42);
        expect(memory.title, 'Old title');
        expect(memory.note, 'Old note');
        expect(memory.imagePath, '/photos/original.jpg');
        expect(memory.latitude, 12.5);
        expect(memory.longitude, 20.5);
        expect(memory.favourite, isTrue);
        expect(memory.createdAt.millisecondsSinceEpoch, 1700000000000);
        expect(memory.updatedAt?.millisecondsSinceEpoch, 1700000010000);
        expect(
          memory.reminderAt?.millisecondsSinceEpoch,
          version == 2 ? 1800000000000 : null,
        );
        expect(memory.folderId, isNull);
        expect(await db.getFolders(), hasLength(8));
      },
    );
  }
}
