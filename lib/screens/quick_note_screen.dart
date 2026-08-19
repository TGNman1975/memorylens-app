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
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _generateTitle(String note) {
    final cleaned = note.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (cleaned.length <= 60) {
      return cleaned;
    }

    return '${cleaned.substring(0, 57).trim()}...';
  }

  Future<void> _save() async {
    final enteredTitle = _titleController.text.trim();
    final note = _noteController.text.trim();

    if (enteredTitle.isEmpty && note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a note before saving.'),
        ),
      );
      return;
    }

    final title =
        enteredTitle.isNotEmpty ? enteredTitle : _generateTitle(note);

    setState(() {
      _saving = true;
    });

    try {
      await context.read<MemoryProvider>().addMemory(
            title: title,
            note: note.isEmpty ? null : note,
            favourite: _favourite,
          );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save memory. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Note'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Optional',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                enabled: !_saving,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'What do you want to remember?',
                  border: OutlineInputBorder(),
                ),
              ),
              SwitchListTile(
                title: const Text('Favourite'),
                value: _favourite,
                onChanged: _saving
                    ? null
                    : (value) {
                        setState(() {
                          _favourite = value;
                        });
                      },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(
                    _saving ? 'Saving...' : 'Save',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}