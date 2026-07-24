import 'dart:io';

import 'package:flutter/material.dart';

class AddMemoryScreen extends StatefulWidget {
  final File image;

  const AddMemoryScreen({
    super.key,
    required this.image,
  });

  @override
  State<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends State<AddMemoryScreen> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Memory"),
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

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {

                  Navigator.pop(
                    context,
                    {
                      "title": _titleController.text,
                      "note": _noteController.text,
                    },
                  );

                },
                child: const Text("Save Memory"),
              ),
            )
          ],
        ),
      ),
    );
  }
}