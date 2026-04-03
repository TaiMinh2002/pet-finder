import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String timeAgo(DateTime date, {String locale = 'en'}) {
    final diff = DateTime.now().difference(date);
    if (locale == 'vi') {
      if (diff.inSeconds < 60) return 'Vừa xong';
      if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
      if (diff.inHours < 24) return '${diff.inHours} giờ trước';
      if (diff.inDays < 7) return '${diff.inDays} ngày trước';
      return DateFormat('dd/MM/yyyy', 'vi').format(date);
    } else {
      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  static String shortDate(DateTime date, {String locale = 'en'}) {
    if (locale == 'vi') return DateFormat('dd/MM/yyyy', 'vi').format(date);
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String fullDateTime(DateTime date, {String locale = 'en'}) {
    if (locale == 'vi') return DateFormat('HH:mm dd/MM/yyyy', 'vi').format(date);
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }
}
