import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../database/app_database.dart';
import '../providers/memory_provider.dart';
import '../services/location_service.dart';

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

  final LocationService _locationService = LocationService();

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

  Future<Position?> _getLocationForSave() async {
    if (_editing) {
      return null;
    }

    try {
      return await _locationService
          .getCurrentLocation()
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Location is optional. A GPS failure must never prevent
      // the memory from being saved.
      return null;
    }
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
        );
      } else {
        final Position? position = await _getLocationForSave();

        await provider.addMemory(
          title: title,
          note: note.isEmpty ? null : note,
          imagePath: widget.image?.path,
          latitude: position?.latitude,
          longitude: position?.longitude,
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
              if (!_editing) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Location will be saved automatically when available.',
                      ),
                    ),
                  ],
                ),
              ],
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
