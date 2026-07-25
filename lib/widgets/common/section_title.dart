import 'package:flutter/material.dart';

/// Displays a reusable section heading.
///
/// Example:
/// ```dart
/// SectionTitle(
///   title: 'Recent Memories',
/// )
/// ```
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.action,
  });

  /// Title displayed on the left.
  final String title;

  /// Optional widget displayed on the right.
  ///
  /// Examples:
  /// - TextButton("See All")
  /// - IconButton(...)
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
  Expanded(
    child: Text(
      title,
      style: theme.textTheme.titleLarge,
    ),
  ),
  if (action != null) action!,
],
    );
  }
}