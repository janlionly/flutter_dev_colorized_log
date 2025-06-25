/*
 * Author: janlionly (janlionly@gmail.com)
 * Date:   2023-09-21
 */
import 'dart:async';
import 'dart:developer' as dev;
import 'package:dev_colorized_log/dev_logger.dart';

import 'package:flutter/foundation.dart';

class DevColorizedLog {
  static final levelEmojis = {
    DevLevel.logNor: '🔖',
    DevLevel.logInf: '📬',
    DevLevel.logSuc: '🎉',
    DevLevel.logWar: '🚧',
    DevLevel.logErr: '❌',
    DevLevel.logBlk: '💣',
  };

  static void logCustom(
    String msg, {
    required DevLevel devLevel,
    bool enable = true,
    int colorInt = 0,
    bool? isLog,
    bool? isMultConsole,
    bool? isDebugPrint,
    String? fileInfo,
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String name = 'logNor',
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
    bool? execFinalFunc,
  }) {
    _custom(
      msg,
      devLevel: devLevel,
      enable: enable,
      colorInt: colorInt,
      isLog: isLog,
      isMultConsole: isMultConsole,
      isDebugPrint: isDebugPrint,
      fileInfo: fileInfo,
      time: time,
      sequenceNumber: sequenceNumber,
      level: level,
      name: name,
      zone: zone,
      error: error,
      stackTrace: stackTrace,
      execFinalFunc: execFinalFunc,
    );
  }

  static void _custom(
    String msg, {
    required DevLevel devLevel,
    bool enable = true,
    int colorInt = 0,
    bool? isLog,
    bool? isMultConsole,
    bool? isDebugPrint,
    String? fileInfo,
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String name = 'logNor',
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
    bool? execFinalFunc,
  }) {
    bool isExe = execFinalFunc != null && execFinalFunc;
    name = '${levelEmojis[devLevel]}:${Dev.prefixName}$name';
    final finalName = isExe
        ? (name.contains('log') ? name.replaceFirst('log', 'exe') : '$name&exe')
        : name;
    DateTime now = DateTime.now();
    String formattedNow = Dev.isLogShowDateTime ? '$now' : '';

    if (error != null) {
      msg = '$msg\n${_errorMessage(error, stackTrace, dateTime: formattedNow)}';
    }

    void logging() {
      if (isExe && !Dev.isExeWithShowLog) {
        return;
      }

      // Process newlines for better search visibility
      final processedMsg = _processNewlines(msg);

      if ((isMultConsole != null && isMultConsole == true) ||
          Dev.isMultConsoleLog) {
        if (isDebugPrint == null || isDebugPrint) {
          debugPrint(
              '\x1B[${colorInt}m[$finalName]$formattedNow${fileInfo ?? ''}${_colorizeLines(processedMsg, colorInt)}\x1B[0m');
        } else {
          // ignore: avoid_print
          print(
              '\x1B[${colorInt}m[$finalName]$formattedNow${fileInfo ?? ''}${_colorizeLines(processedMsg, colorInt)}\x1B[0m');
        }
      } else {
        dev.log(
          '\x1B[${colorInt}m$formattedNow${fileInfo ?? ''}${_colorizeLines(processedMsg, colorInt)}\x1B[0m',
          time: time,
          sequenceNumber: sequenceNumber,
          level: level,
          name: '\x1B[${colorInt}m$finalName\x1B[0m',
          zone: zone,

          /// !!!: handled by _errorMessage above.
          error: null, // error,
          stackTrace: null, //stackTrace,
        );
      }
    }

    if (isLog != null && isLog) {
      logging();
    } else if (enable) {
      if (isLog == null || isLog) {
        logging();
      }
    }

    if (isExe) {
      if (devLevel.index >= Dev.exeLevel.index) {
        final callbackMsg = _processNewlines(msg);
        Dev.customFinalFunc?.call(
            '[$finalName]${Dev.isExeWithDateTime ? '$now' : ''}${fileInfo ?? ''}$callbackMsg',
            devLevel);
      }
    }
  }

  static String _errorMessage(Object error, StackTrace? stackTrace,
      {String? dateTime}) {
    final details = FlutterErrorDetails(exception: error, stack: stackTrace);
    return _errorDetails(details, dateTime: dateTime);
  }

  static String _errorDetails(FlutterErrorDetails details, {String? dateTime}) {
    final timestamp = dateTime != null && dateTime.isNotEmpty
        ? dateTime
        : DateTime.now().toIso8601String();
    final errorId = UniqueKey().toString();
    final errorType = details.exception.runtimeType;
    final errorMessage = details.exceptionAsString();
    final stackTrace = details.stack?.toString() ?? 'No stack trace available';

    return '''
  ❌ [ERROR] UniqueID: $errorId
  🕒 Timestamp: $timestamp
  📛 ErrorType: $errorType
  💥 ErrorMessage: $errorMessage
  📚 StackTrace: \n$stackTrace
  ''';
  }

  static String _colorizeLines(String msg, int colorCode) {
    const lineBreak = '\n';
    if (msg.contains(lineBreak)) {
      return '$lineBreak${msg.split(lineBreak).map((line) => '\x1B[${colorCode}m$line\x1B[0m').join(lineBreak)}';
    }
    return msg;
  }

  /// Process newline characters and clean up whitespace for better search visibility in console
  static String _processNewlines(String msg) {
    if (Dev.isReplaceNewline && msg.contains('\n')) {
      // Replace newlines and clean up extra whitespace characters
      return msg
          .replaceAll('\n', Dev.newlineReplacement)
          .replaceAll('\t', ' ') // Replace tabs with spaces
          .replaceAll(
              RegExp(r' +'), ' ') // Replace multiple spaces with single space
          .trim(); // Remove leading and trailing whitespace
    }
    return msg;
  }
}
