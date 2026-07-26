import 'package:flutter/material.dart';

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

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quick Note save coming next'),
      ),
    );
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