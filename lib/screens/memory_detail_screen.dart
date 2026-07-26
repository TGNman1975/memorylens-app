import 'dart:io';
import 'add_memory_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/app_database.dart';
import '../providers/memory_provider.dart';
import '../utils/date_formatter.dart';

class MemoryDetailScreen extends StatelessWidget {
  Future<void> _openGoogleMaps(
  BuildContext context,
  double latitude,
  double longitude,
) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
  );

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to open Google Maps'),
      ),
    );
  }
}
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
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
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
                if (memory.latitude != null && memory.longitude != null) ...[
  const SizedBox(height: 24),

  Text(
    "Location",
    style: Theme.of(context).textTheme.titleSmall,
  ),

  const SizedBox(height: 8),

  Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Latitude: ${memory.latitude}",
          ),
          const SizedBox(height: 4),
          Text(
            "Longitude: ${memory.longitude}",
          ),
          const SizedBox(height: 16),

          FilledButton.icon(
            onPressed: () => _openGoogleMaps(
              context,
              memory.latitude!,
              memory.longitude!,
            ),
            icon: const Icon(Icons.map),
            label: const Text("Open in Google Maps"),
          ),
        ],
      ),
    ),
  ),
],

                const SizedBox(height: 32),

                FilledButton.icon(
  onPressed: () async {
    if (memory.imagePath == null) return;

    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddMemoryScreen(
          image: File(memory.imagePath!),
          memory: memory,
        ),
      ),
    );

    if (!context.mounted) return;

    if (updated == true) {
      Navigator.pop(context, true);
    }
  },
  icon: const Icon(Icons.edit),
  label: const Text("Edit Memory"),
),

                const SizedBox(height: 12),

                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.delete),
                  label: const Text("Delete Memory"),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text("Delete Memory"),
                        content: const Text(
                          "Are you sure you want to permanently delete this memory?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: const Text("Cancel"),
                          ),
                          FilledButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, true),
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    await context
                        .read<MemoryProvider>()
                        .deleteMemory(memory.id);

                    if (!context.mounted) return;
                      Navigator.pop(context, true);
                    }
              
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