import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';

/// Reusable search bar for filtering memories.
///
/// The widget is stateless and simply reports text changes back to
/// the parent widget via the supplied callback.
class MemorySearchBar extends StatelessWidget {
  const MemorySearchBar({super.key, required this.onChanged, this.controller});

  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        hintText: AppStrings.searchHint,
        prefixIcon: Icon(Icons.search),
      ),
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
    );
  }
}
