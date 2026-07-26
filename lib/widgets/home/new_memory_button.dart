import 'package:flutter/material.dart';

class NewMemoryButton extends StatelessWidget {
  const NewMemoryButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text(
          'New Memory',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}