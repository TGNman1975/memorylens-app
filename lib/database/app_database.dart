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
  int get schemaVersion => 1;

  Future<int> addMemory(MemoriesCompanion memory) {
    return into(memories).insert(memory);
  }

  Future<List<Memory>> getAllMemories() {
    return select(memories).get();
  }

  Future<void> deleteMemory(int id) {
    return (delete(memories)..where((tbl) => tbl.id.equals(id))).go();
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