/*
 * Author: janlionly (janlionly@gmail.com)
 * Date:   2023-09-21
 */
library dev_colorized_log;

import 'dart:developer' as dev;
/// @param static [enable]: whether log msg.
/// @param static [isLogFileInfo]: whether log the location file info.
/// @pararm static [defaultColorInt]: the color int of log text.
class Dev {
  static bool enable = true;
  static bool isLogFileInfo = true;
  static int defaultColorInt = 33;

  /// Default color log, @param[colorInt]: 0 to 107
  static void log(String msg, {int? colorInt}) {
    int ci = colorInt ?? defaultColorInt;
    if (enable) {
      final String fileInfo = Dev.isLogFileInfo ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
      logCustom(msg, colorInt: ci, fileInfo: fileInfo);
    }
  }
  /// Custom color text, @param[colorInt]: 0 to 107
  static void logCustom(String msg, {int colorInt = 33, bool? isLog, String? fileInfo}) {
    if (isLog != null && !isLog) {
      return;
    }
    dev.log('\x1B[${colorInt}m${fileInfo??''}$msg\x1B[0m');
  }
  
  /// Blink orange text
  static void logBlink(String msg, {bool? isLog, bool isSlow = true}) {
    final String fileInfo = Dev.isLogFileInfo ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    logCustom(msg, colorInt: isSlow ? 5 : 6, isLog: isLog, fileInfo: fileInfo);
  }

  /// Blue text
  static void logInfo(String msg, {bool? isLog}) {
    final String fileInfo = Dev.isLogFileInfo ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    logCustom(msg, colorInt: 94, isLog: isLog, fileInfo: fileInfo);
  }

  /// Green text
  static void logSuccess(String msg, {bool? isLog}) {
    final String fileInfo = Dev.isLogFileInfo ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    logCustom(msg, colorInt: 92, isLog: isLog, fileInfo: fileInfo);
  }

  /// Yellow text
  static void logWarning(String msg, {bool? isLog}) {
    final String fileInfo = Dev.isLogFileInfo ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    logCustom(msg, colorInt: 93, isLog: isLog, fileInfo: fileInfo);
  }

  /// Red text
  static void logError(String msg, {bool? isLog}) {
    final String fileInfo = Dev.isLogFileInfo ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    logCustom(msg, colorInt: 91, isLog: isLog, fileInfo: fileInfo);
  }
}