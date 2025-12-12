/*
 * Author: janlionly (janlionly@gmail.com)
 * Date:   2023-09-21
 */
import 'dart:async';
import 'dart:developer' as dev;
import 'package:dev_colorized_log/dev_logger.dart';

import 'package:flutter/foundation.dart';

/// DevColorizedLog - Internal logging implementation with colorized output
///
/// This class provides the core logging functionality with ANSI color codes,
/// emoji indicators, and various formatting options. It handles debouncing,
/// one-time printing, and custom final function execution.
///
/// This is an internal implementation class used by the public Dev API.
class DevColorizedLog {
  /// Emoji indicators for each log level
  /// Maps DevLevel enum values to their corresponding emoji symbols for visual identification
  static final levelEmojis = {
    DevLevel.verbose: '🔍', // Verbose - Detailed debug information
    DevLevel.normal: '🔖', // Normal - General purpose logs
    DevLevel.info: '📬', // Info - Informational messages
    DevLevel.success: '🎉', // Success - Success/completion messages
    DevLevel.warn: '🚧', // Warn - Warning messages
    DevLevel.error: '❌', // Error - Error messages
    DevLevel.fatal: '💣', // Fatal - Fatal/critical errors
  };

  /// Internal flag to prevent infinite recursion
  /// When true, prevents the final function from calling logging methods that would trigger it again
  static bool _isExecutingFinalFunc = false;

  /// Custom log method with full control over formatting and behavior
  /// @param[msg]: The message string to be logged
  /// @param[devLevel]: The log level (verbose, normal, info, success, warn, error, fatal)
  /// @param[enable]: Whether logging is globally enabled
  /// @param[colorInt]: ANSI color code (0-107) for text color customization
  /// @param[isLog]: If set to true, logs regardless of the enable flag
  /// @param[isMultConsole]: If true, uses multi-console logging mode
  /// @param[isDebugPrint]: If true, uses debugPrint; if false, uses print; if null, uses debugPrint in debug mode
  /// @param[fileInfo]: File location information to display in the log
  /// @param[time]: Custom timestamp for the log entry
  /// @param[sequenceNumber]: Sequence number for log ordering
  /// @param[level]: Numeric log level for dart:developer log
  /// @param[name]: Custom name/tag for the log entry
  /// @param[zone]: Dart Zone where the log originates from
  /// @param[error]: Associated error object to be logged alongside the message
  /// @param[stackTrace]: Stack trace information for debugging
  /// @param[execFinalFunc]: If true, executes the custom final function [Dev.exeFinalFunc]
  /// @param[printOnceIfContains]: If provided, only prints once when message contains this keyword
  /// @param[debounceMs]: Debounce time interval in milliseconds, logs within this interval will be discarded
  /// @param[debounceKey]: Custom key for debounce identification (if not provided, uses msg|devLevel|name as fallback)
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
    String? printOnceIfContains,
    int debounceMs = 0,
    String? debounceKey,
  }) {
    // Check debounce - if in debounce period, skip this log
    // Priority: use debounceKey if provided, otherwise fallback to msg|devLevel|name
    if (debounceMs > 0) {
      final key = debounceKey != null
          ? '$debounceKey|$devLevel'
          : '$msg|$devLevel|$name';
      if (Dev.shouldDebounce(key, debounceMs)) {
        return; // Skip this log - still in debounce period
      }
    }

    // Check if message contains keyword and was already logged once
    if (printOnceIfContains != null && msg.contains(printOnceIfContains)) {
      if (Dev.hasCachedKey(printOnceIfContains)) {
        return; // Skip this log - already printed a message containing this keyword
      }
      Dev.addCachedKey(printOnceIfContains);
    }

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
    // Since enum names no longer have 'log' prefix, directly append '&exe' for execution mode
    final finalName = isExe ? '$name&exe' : name;
    DateTime now = DateTime.now();
    String formattedNow = Dev.isLogShowDateTime ? '$now' : '';

    if (error != null) {
      msg = '$msg\n${_errorMessage(error, stackTrace, dateTime: formattedNow)}';
    }

    void logging() {
      if (isExe && !Dev.isExeWithShowLog) {
        return;
      }

      // Check log level filter - skip if log level is below threshold
      if (devLevel.index < Dev.logLevel.index) {
        return; // Skip this log - level below threshold
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

          // !!!: handled by _errorMessage above.
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
        // Use exeFinalFunc first, fall back to customFinalFunc for backward compatibility
        // ignore: deprecated_member_use_from_same_package
        final finalFunc = Dev.exeFinalFunc ?? Dev.customFinalFunc;

        // Prevent infinite recursion when finalFunc calls Dev.exe* methods
        if (finalFunc != null && !_isExecutingFinalFunc) {
          _isExecutingFinalFunc = true;
          try {
            finalFunc.call(
                '[$finalName]${Dev.isExeWithDateTime ? '$now' : ''}${fileInfo ?? ''}$callbackMsg',
                devLevel);
          } finally {
            _isExecutingFinalFunc = false;
          }
        }
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
❌ [ERROR CAPTURED]:
  🆔 Error ID: $errorId
  🕒 Time: $timestamp
  📛 Type: $errorType
  💥 Message: $errorMessage
  📚 Stack Trace:
$stackTrace
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
