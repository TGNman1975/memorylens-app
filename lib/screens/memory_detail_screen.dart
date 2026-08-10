import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/notification_service.dart';
import '../database/app_database.dart';
import '../providers/memory_provider.dart';
import '../utils/date_formatter.dart';
import 'add_memory_screen.dart';

class MemoryDetailScreen extends StatelessWidget {
  const MemoryDetailScreen({
    super.key,
    required this.memory,
  });

  final Memory memory;

  Future<void> _openGoogleMaps(
    BuildContext context,
    double latitude,
    double longitude,
  ) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open Google Maps'),
        ),
      );
    }
  }

  Future<void> _setReminder(BuildContext context) async {
    final now = DateTime.now();

    final initialDate = memory.reminderAt != null &&
            memory.reminderAt!.isAfter(now)
        ? memory.reminderAt!
        : now.add(const Duration(hours: 1));

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(
        initialDate.year,
        initialDate.month,
        initialDate.day,
      ),
      firstDate: DateTime(
        now.year,
        now.month,
        now.day,
      ),
      lastDate: DateTime(now.year + 10),
    );

    if (selectedDate == null || !context.mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (selectedTime == null || !context.mounted) return;

    final reminderAt = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (reminderAt.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose a future date and time.'),
        ),
      );
      return;
    }

    await context.read<MemoryProvider>().updateMemory(
          existing: memory,
          title: memory.title,
          note: memory.note,
          favourite: memory.favourite,
          reminderAt: reminderAt,
        );
await NotificationService.scheduleReminder(
  memoryId: memory.id,
  title: memory.title,
  reminderAt: reminderAt,
);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reminder saved.'),
      ),
    );
  }

  Future<void> _removeReminder(BuildContext context) async {
    await NotificationService.cancelReminder(memory.id);
    await context.read<MemoryProvider>().updateMemory(
          existing: memory,
          title: memory.title,
          note: memory.note,
          favourite: memory.favourite,
          reminderAt: null,
        );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reminder removed.'),
      ),
    );
  }

  String _formatReminder(DateTime reminder) {
    final date =
        '${reminder.day.toString().padLeft(2, '0')}/'
        '${reminder.month.toString().padLeft(2, '0')}/'
        '${reminder.year}';

    final time = TimeOfDay.fromDateTime(reminder).format(
      _currentContext!,
    );

    return '$date at $time';
  }

  BuildContext? _currentContext;

  @override
  Widget build(BuildContext context) {
    _currentContext = context;

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
                        Text('Favourite'),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                Text(
                  'Created',
                  style: Theme.of(context).textTheme.titleSmall,
                ),

                const SizedBox(height: 4),

                Text(
                  DateFormatter.format(memory.createdAt),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 24),

                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.titleSmall,
                ),

                const SizedBox(height: 8),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      (memory.note ?? '').isEmpty
                          ? 'No notes were added.'
                          : memory.note!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Reminder',
                  style: Theme.of(context).textTheme.titleSmall,
                ),

                const SizedBox(height: 8),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (memory.reminderAt == null) ...[
                          const Row(
                            children: [
                              Icon(Icons.notifications_none),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No reminder set',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ] else ...[
                          Row(
                            children: [
                              const Icon(Icons.notifications_active),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _formatReminder(memory.reminderAt!),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => _setReminder(context),
                                icon: const Icon(
                                  Icons.notifications,
                                ),
                                label: Text(
                                  memory.reminderAt == null
                                      ? 'Set Reminder'
                                      : 'Change Reminder',
                                ),
                              ),
                            ),
                            if (memory.reminderAt != null) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: 'Remove reminder',
                                onPressed: () =>
                                    _removeReminder(context),
                                icon: const Icon(
                                  Icons.delete_outline,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                if (memory.latitude != null &&
                    memory.longitude != null) ...[
                  const SizedBox(height: 24),

                  Text(
                    'Location',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),

                  const SizedBox(height: 8),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Latitude: ${memory.latitude}',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Longitude: ${memory.longitude}',
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => _openGoogleMaps(
                              context,
                              memory.latitude!,
                              memory.longitude!,
                            ),
                            icon: const Icon(Icons.map),
                            label: const Text(
                              'Open in Google Maps',
                            ),
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

                    final updated =
                        await Navigator.push<bool>(
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
                  label: const Text('Edit Memory'),
                ),

                const SizedBox(height: 12),

                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete Memory'),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) =>
                          AlertDialog(
                        title: const Text('Delete Memory'),
                        content: const Text(
                          'Are you sure you want to permanently '
                          'delete this memory?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(
                              dialogContext,
                              false,
                            ),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () =>
                                Navigator.pop(
                              dialogContext,
                              true,
                            ),
                            child: const Text('Delete'),
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
                  },
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}