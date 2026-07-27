import 'package:flutter/material.dart';

import '../../database/app_database.dart';
import '../../utils/date_grouping.dart';
import '../memory/memory_card.dart';
import 'empty_state.dart';
import 'memory_date_header.dart';

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
      return const EmptyState(
        message: 'Start by creating your first memory.',
        icon: Icons.auto_stories_outlined,
      );
    }

    String? currentGroup;

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh will be connected to MemoryProvider later.
      },
      child: ListView.builder(
        itemCount: memories.length,
        itemBuilder: (context, index) {
          final memory = memories[index];
          final group = DateGrouping.label(memory.createdAt);

          final widgets = <Widget>[];

          if (group != currentGroup) {
            currentGroup = group;
            widgets.add(
              MemoryDateHeader(
                title: group,
              ),
            );
          }

          widgets.add(
            MemoryCard(
              memory: memory,
              onTap: () => onTap(memory),
              onDelete: () => onDelete(memory),
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          );
        },
      ),
    );
  }
}