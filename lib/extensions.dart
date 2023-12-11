import 'package:ctrader_example_app/remote/proto.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

extension ColorExtention on Color {
  ColorFilter get asFilter => ColorFilter.mode(this, BlendMode.srcIn);
}

extension DoubleExtention on double {
  /// if decimals = null - it will auto format floating part of the number
  String toComaSeparated({int? decimals}) {
    final StringBuffer buffer = StringBuffer();
    final int integer = abs().floor();
    if (sign.isNegative) buffer.write('-');
    buffer.write(integer.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match match) => '${match.group(0)},'));

    if (decimals != null && decimals > 0) {
      buffer.write('.');
      buffer.write(toStringAsFixed(decimals).split('.')[1]);
    } else if (decimals != 0) {
      final String remander = toString().split('.')[1];
      if (remander != '0') {
        buffer.write('.');
        buffer.write(remander);
      }
    }

    return buffer.toString();
  }
}

extension DateTimeExtention on DateTime {
  DateTime previousSundayMidnight() {
    final DateTime d = subtract(Duration(
      days: weekday % 7,
      hours: hour,
      minutes: minute,
      seconds: second,
      milliseconds: millisecond,
      microseconds: microsecond,
    ));
    return d;
  }

  int get daysSinceEpoch => difference(DateTime(1970)).inDays;
  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;

  DateTime updateTime({int? hours, int? minutes, int? seconds, int? milliseconds, int? microseconds}) {
    return DateTime(
      year,
      month,
      day,
      hours ?? hour,
      minutes ?? minute,
      seconds ?? second,
      milliseconds ?? millisecond,
      microseconds ?? microsecond,
    );
  }

  DateTime addPeriod({int? years, int? monthes, int? days}) {
    return DateTime(
      year + (years ?? 0),
      month + (monthes ?? 0),
      day + (days ?? 0),
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  String formatted([String format = 'HH:mm:ss, d MMMM y']) => DateFormat(format).format(this);
}

extension ProtoOAHolidayExtention on ProtoOAHoliday {
  /// Return DateTime of the event start in event timezone
  DateTime startDateTime() {
    final tz.Location location = tz.getLocation(scheduleTimeZone);
    return tz.TZDateTime(location, 1970, DateTime.january, holidayDate + 1, 0, 0, startSecond ?? 0).toLocal();
  }

  /// Eeturn DateTime of the event end in event timezone
  /// if endSecond is empty or 0 then return the end of the day
  DateTime endDateTime() {
    final tz.Location location = tz.getLocation(scheduleTimeZone);
    return tz.TZDateTime(
      location,
      1970,
      DateTime.january,
      holidayDate + 1,
      0,
      0,
      (endSecond != null && endSecond! > 0 ? endSecond! : 86400) - 1,
    ).toLocal();
  }
}

extension ProtoOATrendbarPeriodExtention on ProtoOATrendbarPeriod {
  static ProtoOATrendbarPeriod byChartName(String name) {
    name = name.toUpperCase();

    if (name == '1M') return ProtoOATrendbarPeriod.m1;
    // if (name == "2M") return ProtoOATrendbarPeriod.m2;
    // if (name == "3M") return ProtoOATrendbarPeriod.m3;
    // if (name == "4M") return ProtoOATrendbarPeriod.m4;
    if (name == '5M') return ProtoOATrendbarPeriod.m5;
    // if (name == "10M") return ProtoOATrendbarPeriod.m10;
    if (name == '15M') return ProtoOATrendbarPeriod.m15;
    if (name == '30M') return ProtoOATrendbarPeriod.m30;
    if (name == '1H') return ProtoOATrendbarPeriod.h1;
    if (name == '4H') return ProtoOATrendbarPeriod.h4;
    // if (name == "12H") return ProtoOATrendbarPeriod.h12;
    if (name == '1D') return ProtoOATrendbarPeriod.d1;
    if (name == '1W') return ProtoOATrendbarPeriod.w1;
    // if (name == "") return ProtoOATrendbarPeriod.mn1;

    return ProtoOATrendbarPeriod.m5;
  }

  int seconds() {
    switch (this) {
      case ProtoOATrendbarPeriod.undefined:
        return 0;
      case ProtoOATrendbarPeriod.m1:
        return 60;
      case ProtoOATrendbarPeriod.m2:
        return 120;
      case ProtoOATrendbarPeriod.m3:
        return 180;
      case ProtoOATrendbarPeriod.m4:
        return 240;
      case ProtoOATrendbarPeriod.m5:
        return 300;
      case ProtoOATrendbarPeriod.m10:
        return 600;
      case ProtoOATrendbarPeriod.m15:
        return 900;
      case ProtoOATrendbarPeriod.m30:
        return 1800;
      case ProtoOATrendbarPeriod.h1:
        return 3600;
      case ProtoOATrendbarPeriod.h4:
        return 14400;
      case ProtoOATrendbarPeriod.h12:
        return 43200;
      case ProtoOATrendbarPeriod.d1:
        return 86400;
      case ProtoOATrendbarPeriod.w1:
        return 604800;
      case ProtoOATrendbarPeriod.mn1:
        return 2592000;
    }
  }

  String toChartName() {
    switch (this) {
      case ProtoOATrendbarPeriod.m1:
        return '1M';
      case ProtoOATrendbarPeriod.m2:
        return '2M';
      case ProtoOATrendbarPeriod.m3:
        return '3M';
      case ProtoOATrendbarPeriod.m4:
        return '4M';
      case ProtoOATrendbarPeriod.m5:
        return '5M';
      case ProtoOATrendbarPeriod.m10:
        return '10M';
      case ProtoOATrendbarPeriod.m15:
        return '15M';
      case ProtoOATrendbarPeriod.m30:
        return '30M';
      case ProtoOATrendbarPeriod.h1:
        return '1H';
      case ProtoOATrendbarPeriod.h4:
        return '4H';
      case ProtoOATrendbarPeriod.h12:
        return '12H';
      case ProtoOATrendbarPeriod.d1:
        return '1D';
      case ProtoOATrendbarPeriod.w1:
        return '1W';
      case ProtoOATrendbarPeriod.mn1:
        return '1MN';

      default:
        return 'n/a';
    }
  }
}

extension MapExtention<K, V> on Map<K, V> {
  V? valueWhere(bool Function(V value) test) {
    for (final V value in values) {
      if (test(value)) return value;
    }

    return null;
  }
}

extension StringExtension on String {
  String centerLabel(int width, [String symbol = ' ']) => padLeft(width ~/ 2 + length ~/ 2, symbol).padRight(width, symbol);
}
