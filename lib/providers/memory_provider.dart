import 'package:flutter/material.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../repositories/memory_repository.dart';

class MemoryProvider extends ChangeNotifier {
  final MemoryRepository repository;

  MemoryProvider(this.repository);

  List<Memory> _memories = [];

  List<Memory> get memories => _memories;
    int get totalMemories => _memories.length;

int get favouriteCount =>
    _memories.where((m) => m.favourite).length;

int get photoCount =>
    _memories.where((m) => m.imagePath != null).length;

int get quickNoteCount =>
    _memories.where((m) => m.imagePath == null).length;

int get locationCount =>
    _memories.where(
      (m) => m.latitude != null && m.longitude != null,
    ).length;
  // ---------------------------------------------------------------------------
  // Load
  // ---------------------------------------------------------------------------

  Future<void> loadMemories() async {
    _memories = await repository.getAll();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Create
  // ---------------------------------------------------------------------------

  Future<void> addMemory({
  required String title,
  String? note,
  String? imagePath,
  double? latitude,
  double? longitude,
  bool favourite = false,
}) async {
  await repository.add(
    MemoriesCompanion.insert(
      title: title,
      note: Value(note),
      imagePath: Value(imagePath),
      latitude: Value(latitude),
      longitude: Value(longitude),
      favourite: Value(favourite),
    ),
  );

  await loadMemories();
}

  // ---------------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------------

  Future<void> updateMemory({
  required Memory existing,
  required String title,
  String? note,
  bool favourite = false,
}) async {
  final updated = existing.copyWith(
    title: title,
    note: Value(note),
    favourite: favourite,
  );

  await repository.update(updated);
  await loadMemories();
}

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  Future<void> deleteMemory(int id) async {
    await repository.delete(id);
    await loadMemories();
  }
}