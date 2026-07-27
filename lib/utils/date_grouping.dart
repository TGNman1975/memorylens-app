import 'package:intl/intl.dart';

class DateGrouping {
  static String label(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final days = today.difference(target).inDays;

    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return 'This Week';
    if (days < 30) return 'This Month';
    if (days < 365) return DateFormat('MMMM').format(date);

    return DateFormat('MMMM yyyy').format(date);
  }
}