
/*
 * Author: janlionly (janlionly@gmail.com)
 * Date:   2023-09-21
 */
import 'dart:async';
import 'dart:developer' as dev;

/// @param static [enable]: whether log msg.
/// @param static [isLogFileInfo]: whether log the location file info.
/// @pararm static [defaultColorInt]: the color int of log text.
class Dev {
  static bool enable = true;
  static bool isLogFileInfo = true;
  static int defaultColorInt = 0;

  /// Default color log, @param[colorInt]: 0 to 107
  static void log(String msg, {
    bool? isLog, 
    int? colorInt,
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String name = '',
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
    }) {
    _custom(msg, 
      isLog: isLog, 
      colorInt: colorInt,
      time: time,
      sequenceNumber: sequenceNumber,
      level: level,
      name: name,
      zone: zone,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void _custom(String msg, {
    bool? isLog, 
    int? colorInt,
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String name = '',
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
    }) {
    int ci = colorInt ?? defaultColorInt;
    final String fileInfo = Dev.isLogFileInfo ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    _logCustom(msg, 
      colorInt: ci, 
      isLog: isLog, 
      fileInfo: fileInfo,
      time: time,
      sequenceNumber: sequenceNumber,
      level: level,
      name: name,
      zone: zone,
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  // Custom color text, @param[colorInt]: 0 to 107
  static void _logCustom(String msg, {
    int colorInt = 0, 
    bool? isLog, 
    String? fileInfo,
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String name = '',
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
    }) {
    if (!enable) {
      return;
    }
    if (isLog != null && !isLog) {
      return;
    }
    dev.log('\x1B[${colorInt}m${fileInfo??''}$msg\x1B[0m', 
      time: time,
      sequenceNumber: sequenceNumber,
      level: level,
      name: name.isEmpty ? 'logNor' : name,
      zone: zone,
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Blink orange text
  static void logBlink(String msg, {bool? isLog, bool isSlow = true}) {
    _blink(msg, isLog: isLog, isSlow: isSlow);
  }

  static void _blink(String msg, {bool? isLog, bool isSlow = true}) {
    final String fileInfo = Dev.isLogFileInfo ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    _logCustom(msg, colorInt: isSlow ? 5 : 6, isLog: isLog, fileInfo: fileInfo, name: 'logBlk');
  }

  /// Blue text
  static void logInfo(String msg, {bool? isLog}) {
    _info(msg, isLog: isLog);
  }

  static void _info(String msg, {bool? isLog}) {
    final String fileInfo = Dev.isLogFileInfo ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    _logCustom(msg, colorInt: 96, isLog: isLog, fileInfo: fileInfo, name: 'logInf');
  }

  /// Green text
  static void logSuccess(String msg, {bool? isLog}) {
    _success(msg, isLog: isLog);
  }

  static void _success(String msg, {bool? isLog}) {
    final String fileInfo = Dev.isLogFileInfo ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    _logCustom(msg, colorInt: 92, isLog: isLog, fileInfo: fileInfo, name: 'logSuc');
  }

  /// Yellow text
  static void logWarning(String msg, {bool? isLog}) {
    _warning(msg, isLog: isLog);
  }

  static void _warning(String msg, {bool? isLog}) {
    final String fileInfo = Dev.isLogFileInfo ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    _logCustom(msg, colorInt: 93, isLog: isLog, fileInfo: fileInfo, level: 1000, name: 'logWar');
  }

  /// Red text
  static void logError(String msg, {bool? isLog}) {
    _error(msg, isLog: isLog);
  }

  static void _error(String msg, {bool? isLog}) {
    final String fileInfo = Dev.isLogFileInfo ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    _logCustom(msg, colorInt: 91, isLog: isLog, fileInfo: fileInfo, level: 2000, name: 'logErr');
  }
}
