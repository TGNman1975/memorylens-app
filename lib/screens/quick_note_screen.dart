import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/memory_provider.dart';



class QuickNoteScreen extends StatefulWidget {
  const QuickNoteScreen({super.key});

  @override
  State<QuickNoteScreen> createState() => _QuickNoteScreenState();
}

class _QuickNoteScreenState extends State<QuickNoteScreen> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  bool _favourite = false;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
  final title = _titleController.text.trim();

  if (title.isEmpty) return;

  await context.read<MemoryProvider>().addMemory(
    title: title,
    note: _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim(),
    favourite: _favourite,
  );

  if (!mounted) return;

  Navigator.pop(context, true);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Notes',
              ),
            ),
            SwitchListTile(
              title: const Text('Favourite'),
              value: _favourite,
              onChanged: (value) {
                setState(() {
                  _favourite = value;
                });
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}