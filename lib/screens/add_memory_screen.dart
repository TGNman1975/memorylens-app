import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../database/app_database.dart';
import '../providers/memory_provider.dart';
import '../services/location_service.dart';

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

  final LocationService _locationService = LocationService();

  bool _saving = false;
  bool _loadingLocation = true;
  bool _favourite = false;

  double? _latitude;
  double? _longitude;

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

    if (_editing) {
      _latitude = widget.memory?.latitude;
      _longitude = widget.memory?.longitude;
      _loadingLocation = false;
    } else {
      _loadLocation();
    }
  }

  Future<void> _loadLocation() async {
    try {
      final Position position = await _locationService
          .getCurrentLocation()
          .timeout(const Duration(seconds: 5));

      if (!mounted) return;

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (_) {
      // GPS unavailable or timed out.
      // Saving will continue without coordinates.
    } finally {
      if (!mounted) return;

      setState(() {
        _loadingLocation = false;
      });
    }
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

  if (_editing) {
    await provider.updateMemory(
      existing: widget.memory!,
      title: title,
      note: note.isEmpty ? null : note,
      favourite: _favourite,
    );
  } else {
    await provider.addMemory(
      title: title,
      note: note.isEmpty ? null : note,
      imagePath: widget.image.path,
      latitude: _latitude,
      longitude: _longitude,
      favourite: _favourite,
    );
  }

  if (!mounted) return;

  Navigator.pop(context, true);
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
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  widget.image,
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
                onChanged: (value) {
                  setState(() {
                    _favourite = value;
                  });
                },
              ),

              const SizedBox(height: 8),

Row(
  children: [
    Icon(
      _loadingLocation
          ? Icons.location_searching
          : (_latitude != null
              ? Icons.location_on
              : Icons.location_off),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: Text(
        _loadingLocation
            ? 'Getting GPS location...'
            : (_latitude != null
                ? 'Location captured'
                : 'Location unavailable'),
      ),
    ),
  ],
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