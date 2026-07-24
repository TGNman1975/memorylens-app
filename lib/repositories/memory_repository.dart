import '../database/app_database.dart';

class MemoryRepository {
  final AppDatabase database;

  MemoryRepository(this.database);

  Future<List<Memory>> getAll() {
    return database.getAllMemories();
  }

  Future<void> add(MemoriesCompanion memory) {
    return database.addMemory(memory);
  }

  Future<void> delete(int id) {
    return database.deleteMemory(id);
  }
}