import 'dart:io';

import 'package:flutter/material.dart';

import '../../utils/date_formatter.dart';
import '../../database/app_database.dart';

/// Displays a single memory.
///
/// This widget is responsible only for presentation.
/// It contains no Provider or database logic.
class MemoryCard extends StatelessWidget {
  const MemoryCard({
    super.key,
    required this.memory,
    required this.onTap,
    required this.onDelete,
  });

  final Memory memory;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(memory.id),
      direction: DismissDirection.endToStart,

      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Delete Memory'),
                content: const Text(
                  'Are you sure you want to delete this memory?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;
      },

      onDismissed: (_) => onDelete(),

      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),

      child: Card(
        margin: const EdgeInsets.only(bottom: 12),

        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,

          child: Padding(
            padding: const EdgeInsets.all(12),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumbnail(),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              memory.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          if (memory.favourite)
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                        ],
                      ),

                      if ((memory.note ?? "").isNotEmpty) ...[
                        const SizedBox(height: 6),

                        Text(
                          memory.note!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 8),

                      Text(
                        DateFormatter.format(memory.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (memory.imagePath == null) {
      return Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade800,
        ),
        child: Icon(
  memory.imagePath == null
      ? Icons.sticky_note_2_outlined
      : Icons.photo,
  size: 32,
  color: Colors.white70,
),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(memory.imagePath!),
        width: 72,
        height: 72,
        fit: BoxFit.cover,
      ),
    );
  }
}