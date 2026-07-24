import 'dart:io';

import 'package:flutter/material.dart';
import '../database/app_database.dart';

class AddMemoryScreen extends StatefulWidget {
  final File image;
  final Memory? memory;

  const AddMemoryScreen({
    super.key,
    required this.image,
    this.memory,
  });

  @override
  State<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends State<AddMemoryScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;

  bool _favourite = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.memory?.title ?? "",
    );

    _noteController = TextEditingController(
      text: widget.memory?.note ?? "",
    );

    _favourite = widget.memory?.favourite ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.memory != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? "Edit Memory" : "New Memory"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                widget.image,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Title",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Notes",
              ),
            ),

            const SizedBox(height: 12),

            SwitchListTile(
              value: _favourite,
              title: const Text("Favourite"),
              onChanged: (value) {
                setState(() {
                  _favourite = value;
                });
              },
            ),

            const Spacer(),

            FilledButton(
              onPressed: () {
                Navigator.pop(context, {
                  "title": _titleController.text.trim(),
                  "note": _noteController.text.trim(),
                  "favourite": _favourite,
                });
              },
              child: Text(editing ? "Save Changes" : "Save Memory"),
            )
          ],
        ),
      ),
    );
  }
}