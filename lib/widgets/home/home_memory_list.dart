import 'package:flutter/material.dart';

import '../../database/app_database.dart';
import '../memory/memory_card.dart';

class HomeMemoryList extends StatelessWidget {
  const HomeMemoryList({
    super.key,
    required this.memories,
    required this.onTap,
    required this.onDelete,
  });

  final List<Memory> memories;
  final Future<void> Function(Memory memory) onTap;
  final Future<void> Function(Memory memory) onDelete;

  @override
  Widget build(BuildContext context) {
    if (memories.isEmpty) {
      return const Center(
        child: Text('No memories yet'),
      );
    }

    return ListView.builder(
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final memory = memories[index];

        return MemoryCard(
          memory: memory,
          onTap: () => onTap(memory),
          onDelete: () => onDelete(memory),
        );
      },
    );
  }
}