extension DateTimeExtension on DateTime {
  String humanReadable() {
    DateTime now = DateTime.now();
    if (now.difference(this) < Duration(minutes: 10)) return "Ahora";
    return "$hour:${minute.toString().padLeft(2, '0')}";
  }
}
