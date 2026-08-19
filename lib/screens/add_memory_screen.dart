import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/app_database.dart';
import '../providers/memory_provider.dart';

class AddMemoryScreen extends StatefulWidget {
  final File? image;
  final Memory? memory;

  const AddMemoryScreen({
    super.key,
    this.image,
    this.memory,
  });

  @override
  State<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends State<AddMemoryScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;

  bool _saving = false;
  bool _favourite = false;

  bool get _editing => widget.memory != null;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.memory?.title ?? '',
    );

    _noteController = TextEditingController(
      text: widget.memory?.note ?? '',
    );

    _favourite = widget.memory?.favourite ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveMemory() async {
    final title = _titleController.text.trim();
    final note = _noteController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    final provider = context.read<MemoryProvider>();

    try {
      if (_editing) {
        await provider.updateMemory(
         existing: widget.memory!,
         title: title,
         note: note.isEmpty ? null : note,
         favourite: _favourite,
          reminderAt: widget.memory!.reminderAt,
        );
      } else {
        await provider.addMemory(
          title: title,
          note: note.isEmpty ? null : note,
          imagePath: widget.image?.path,
          favourite: _favourite,
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
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
        title: Text(
          _editing ? 'Edit Memory' : 'New Memory',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (widget.image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    widget.image!,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _favourite,
                title: const Text('Favourite'),
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
                child: FilledButton.icon(
                  onPressed: _saving ? null : _saveMemory,
                  icon: Icon(
                    _editing ? Icons.save : Icons.add,
                  ),
                  label: Text(
                    _saving
                        ? 'Saving...'
                        : (_editing
                            ? 'Save Changes'
                            : 'Save Memory'),
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
