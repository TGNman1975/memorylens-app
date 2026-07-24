import 'dart:io';

import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../utils/date_formatter.dart';

class MemoryDetailScreen extends StatelessWidget {
  final Memory memory;

  const MemoryDetailScreen({
    super.key,
    required this.memory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory'),
      ),
      body: ListView(
        children: [
          Hero(
            tag: 'memory_${memory.id}',
            child: memory.imagePath != null
                ? Image.file(
                    File(memory.imagePath!),
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 300,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Icon(
                      Icons.photo,
                      size: 100,
                    ),
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memory.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 12),

                if (memory.favourite)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 18,
                          color: Colors.amber,
                        ),
                        SizedBox(width: 6),
                        Text("Favourite"),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                Text(
                  "Created",
                  style: Theme.of(context).textTheme.titleSmall,
                ),

                const SizedBox(height: 4),

                Text(
                  DateFormatter.format(memory.createdAt),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 24),

                Text(
                  "Notes",
                  style: Theme.of(context).textTheme.titleSmall,
                ),

                const SizedBox(height: 8),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      (memory.note ?? '').isEmpty
                          ? "No notes were added."
                          : memory.note!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Edit Memory coming soon',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Memory"),
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Back"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}