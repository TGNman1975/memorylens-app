import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/memories.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Memories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(
              memories,
              memories.reminderAt,
            );
          }
        },
      );

  Future<int> addMemory(MemoriesCompanion memory) {
    return into(memories).insert(memory);
  }

  Future<List<Memory>> getAllMemories() {
    return (select(memories)
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .get();
  }

  Future<Memory?> getMemory(int id) {
    return (select(memories)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<bool> updateMemory(Memory memory) {
    return update(memories).replace(memory);
  }

  Future<void> deleteMemory(int id) {
    return (delete(memories)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();

    final file = File(
      p.join(dbFolder.path, 'memory_lens.sqlite'),
    );

    return NativeDatabase(file);
  });
}