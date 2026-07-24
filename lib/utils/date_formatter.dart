import 'package:intl/intl.dart';

class DateFormatter {
  static String format(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final memoryDay = DateTime(date.year, date.month, date.day);

    if (memoryDay == today) {
      return "Today • ${DateFormat.jm().format(date)}";
    }

    if (memoryDay == yesterday) {
      return "Yesterday • ${DateFormat.jm().format(date)}";
    }

    return DateFormat("dd MMM yyyy • h:mm a").format(date);
  }
}