import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/memories.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Memories, Folders])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  AppDatabase.forTesting(super.e);

  Future<void> _seedFolders() async {
    for (final name in const [
      'Home',
      'Family & Friends',
      'Health',
      'Travel',
      'Work',
      'Shopping',
      'Important',
      'Ideas',
    ]) {
      await saveFolder(name);
    }
  }

  Future<List<Folder>> getFolders() =>
      (select(folders)..orderBy([(f) => OrderingTerm.asc(f.nameKey)])).get();

  Future<int> saveFolder(String name, {int? id}) async {
    final title = name.trim();
    if (title.isEmpty) throw ArgumentError('Enter a folder name.');
    final key = title.toLowerCase();
    if (key == 'all memories' || key == 'unfiled') {
      throw ArgumentError(
        'Choose a different name. This name is used by a system view.',
      );
    }
    final values = FoldersCompanion.insert(name: title, nameKey: key);
    return transaction(() async {
      final existing = await (select(
        folders,
      )..where((f) => f.nameKey.equals(key))).getSingleOrNull();
      if (existing != null && existing.id != id) {
        throw ArgumentError('A folder with this name already exists.');
      }
      if (id == null) return into(folders).insert(values);
      await (update(folders)..where((f) => f.id.equals(id))).write(values);
      return id;
    });
  }

  Future<void> deleteFolder(int id) async {
    await (delete(folders)..where((f) => f.id.equals(id))).go();
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await transaction(() async {
        await m.createAll();
        await _seedFolders();
      });
    },
    onUpgrade: (Migrator m, int from, int to) async {
      await transaction(() async {
        if (from < 2) {
          await m.addColumn(memories, memories.reminderAt);
        }
        if (from < 3) {
          await m.createTable(folders);
          await m.addColumn(memories, memories.folderId);
          await _seedFolders();
        }
      });
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<int> addMemory(MemoriesCompanion memory) {
    return into(memories).insert(memory);
  }

  Future<List<Memory>> getAllMemories() {
    return (select(
      memories,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  Future<Memory?> getMemory(int id) {
    return (select(
      memories,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<bool> updateMemory(Memory memory) {
    return update(memories).replace(memory);
  }

  Future<void> deleteMemory(int id) {
    return (delete(memories)..where((tbl) => tbl.id.equals(id))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();

    final file = File(p.join(dbFolder.path, 'memory_lens.sqlite'));

    return NativeDatabase(file);
  });
}
