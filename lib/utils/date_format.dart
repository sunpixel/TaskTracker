String _two(int n) => n.toString().padLeft(2, '0');

/// European-style date: DD-MM-YYYY.
String formatDate(DateTime dt) => '${_two(dt.day)}-${_two(dt.month)}-${dt.year}';

/// Time first, then the European date: HH:MM DD-MM-YYYY.
String formatDateTime(DateTime dt) =>
    '${_two(dt.hour)}:${_two(dt.minute)} ${formatDate(dt)}';
