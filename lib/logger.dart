import 'dart:math';

import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/models/internal_application_error.dart';
import 'package:ctrader_example_app/remote/proto.dart';
import 'package:intl/intl.dart';

enum LoggerLevel {
  ERROR,
  LOG,
  DEBUG,
}

class Logger {
  static final Logger _instance = Logger();
  static Logger get I => _instance;
  static Logger get instance => _instance;

  LoggerLevel level = LoggerLevel.LOG;
  String title = 'LOGGER';
  bool printTime = true;

  /// max line width to print to console is 1023
  int maxWidth = 1023;

  static bool get isDebugEnabled => I.level.index >= LoggerLevel.DEBUG.index;
  static bool get isLogEnabled => I.level.index >= LoggerLevel.LOG.index;

  static String _currentTS() {
    final DateTime now = DateTime.now().toUtc();
    final String date = DateFormat('MM-dd HH:mm:ss').format(now);

    return '[$date.${now.millisecond.toString().padLeft(3, '0')}]';
  }

  static void _print(String tag, String message) {
    final int splitLength = min(I.maxWidth, 1023) - tag.length - 1;
    final List<String> split = message.split('\n');
    final RegExp regExp = RegExp(r'.{1,' + splitLength.toString() + '}');

    for (final String line in split) {
      final Iterable<RegExpMatch> matches = regExp.allMatches(line);
      for (final RegExpMatch match in matches) {
        print('$tag ${match[0]}');
      }
    }
  }

  static void debug(String Function() messageFunc) {
    if (!isDebugEnabled) return;

    final String message = messageFunc();
    final String tag = '[${I.title}.DEBUG]';
    final String time = I.printTime ? _currentTS() : '';

    if ((tag.length + time.length + message.length) < 1022) {
      _print('$time$tag', message);
    } else {
      _print('$time$tag', '${' MESSAGE START '.centerLabel(80, '-')}\n$message\n${' MESSAGE END '.centerLabel(80, '-')}');
    }
  }

  static void log(String Function() messageFunc) {
    if (!isLogEnabled) return;

    _print('${I.printTime ? _currentTS() : ''}[${I.title}.INFO ]', messageFunc());
  }

  static void error(String message, [Object? err, StackTrace? stackTrace]) {
    final StringBuffer errPrint = StringBuffer();
    errPrint.writeln(message);

    if (err != null) {
      errPrint.write('[${err.runtimeType}] ');

      if (err is ProtoOAErrorRes) {
        errPrint.write('#${err.errorCode}: ${err.description}');
      } else if (err is InternalApplicationError) {
        errPrint.write('#${err.code}: ${err.description}');
      } else {
        errPrint.writeln(err);
      }
    }

    if (stackTrace != null) {
      errPrint.writeln(stackTrace.toString());
    }

    _print('${I.printTime ? _currentTS() : ''}[${I.title}.ERROR]', errPrint.toString());
  }
}
