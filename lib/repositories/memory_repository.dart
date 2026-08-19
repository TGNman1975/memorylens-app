import '../database/app_database.dart';
import '../services/image_storage_service.dart';
import '../services/notification_service.dart';

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
    final memory = await database.getMemory(id);

    if (memory == null) {
      return;
    }

    await NotificationService.cancelReminder(memory.id);

    await database.deleteMemory(id);

    await ImageStorageService.deleteImage(memory.imagePath);
  }
}