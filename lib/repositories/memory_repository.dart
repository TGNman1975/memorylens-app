import '../database/app_database.dart';

class MemoryRepository {
  final AppDatabase database;

  MemoryRepository(this.database);

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  Future<List<Memory>> getAll() {
    return database.getAllMemories();
  }

  // ---------------------------------------------------------------------------
  // Create
  // ---------------------------------------------------------------------------

  Future<void> add(MemoriesCompanion memory) async {
    await database.addMemory(memory);
  }

  // ---------------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------------

  Future<void> update(Memory memory) async {
    await database.updateMemory(memory);
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  Future<void> delete(int id) async {
    await database.deleteMemory(id);
  }
}