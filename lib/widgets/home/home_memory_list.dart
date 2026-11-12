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
    this.header,
    this.padding,
    required this.onTap,
    required this.onDelete,
  });

  final List<Memory> memories;
  final Widget? header;
  final EdgeInsetsGeometry? padding;
  final Future<void> Function(Memory memory) onTap;
  final Future<void> Function(Memory memory) onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.only(bottom: 24),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount:
          (header == null ? 0 : 1) + (memories.isEmpty ? 1 : memories.length),
      itemBuilder: (context, index) {
        if (header != null && index == 0) return header!;
        if (memories.isEmpty) {
          return EmptyState(
            message: header == null
                ? 'No memories to show.'
                : 'No memories match your search or filter.',
            icon: Icons.search_off_outlined,
          );
        }
        final memoryIndex = index - (header == null ? 0 : 1);
        final memory = memories[memoryIndex];
        final group = DateGrouping.label(memory.createdAt);

        final widgets = <Widget>[];

        if (memoryIndex == 0 ||
            group != DateGrouping.label(memories[memoryIndex - 1].createdAt)) {
          widgets.add(MemoryDateHeader(title: group));
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
    );
  }
}
