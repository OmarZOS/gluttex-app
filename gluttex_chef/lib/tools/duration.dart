import 'dart:developer';

Duration ParseDurationString(String durationString) {
  final RegExp hourRegex = RegExp(r'(\d+)\s*hours');
  final RegExp minuteRegex = RegExp(r'(\d+)\s*minutes');

  int hours = 0;
  int minutes = 0;

  final hourMatch = hourRegex.firstMatch(durationString);
  if (hourMatch != null) {
    hours = int.parse(hourMatch.group(1)!);
  }

  final minuteMatch = minuteRegex.firstMatch(durationString);
  log('${hourMatch?.group(1)} ');
  log('${minuteMatch?.group(1)} ');
  if (minuteMatch != null) {
    minutes = int.parse(minuteMatch.group(1)!);
  }

  return Duration(hours: hours, minutes: minutes);
}
