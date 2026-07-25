import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';

/// Primary action button used to capture a new memory.
class CaptureButton extends StatelessWidget {
  const CaptureButton({
    super.key,
    required this.onPressed,
  });

  /// Called when the user taps the button.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text(AppStrings.captureMemory),
      ),
    );
  }
}