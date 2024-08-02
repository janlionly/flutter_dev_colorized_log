/*
 * Author: janlionly (janlionly@gmail.com)
 * Date:   2023-09-21
 */
import 'dart:async';
import 'customized_logger.dart';

/// @param static [enable]: whether log msg.
/// @param static [isLogFileInfo]: whether log the location file info.
/// @pararm static [defaultColorInt]: the color int of log text.
class Dev {
  static bool enable = true;
  static bool isLogFileInfo = true;
  static int defaultColorInt = 0;

  /// Default color log
  /// @param[colorInt]: 0 to 107
  static void log(String msg, {
    bool? isLog, 
    int? colorInt,
    String? fileLocation,
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String name = 'logNor',
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
    }) {
    int ci = colorInt ?? defaultColorInt;
    final String fileInfo = Dev.isLogFileInfo ? 
    (fileLocation != null ? '($fileLocation): ' : '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ')
     : '';
    DevColorizedLog.logCustom(msg,
      enable: Dev.enable,
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
  
  /// Blink orange text
  static void logBlink(String msg, {bool? isLog, bool isSlow = true}) {
    final String fileInfo = Dev.isLogFileInfo ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    DevColorizedLog.logCustom(msg, enable: Dev.enable, colorInt: isSlow ? 5 : 6, isLog: isLog, fileInfo: fileInfo, name: 'logBlk');
  }


  /// Blue text
  static void logInfo(String msg, {bool? isLog}) {
    final String fileInfo = Dev.isLogFileInfo ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    DevColorizedLog.logCustom(msg, enable: Dev.enable, colorInt: 96, isLog: isLog, fileInfo: fileInfo, name: 'logInf');
  }


  /// Green text
  static void logSuccess(String msg, {bool? isLog}) {
    final String fileInfo = Dev.isLogFileInfo ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    DevColorizedLog.logCustom(msg, enable: Dev.enable, colorInt: 92, isLog: isLog, fileInfo: fileInfo, name: 'logSuc');
  }


  /// Yellow text
  static void logWarning(String msg, {bool? isLog}) {
    final String fileInfo = Dev.isLogFileInfo ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    DevColorizedLog.logCustom(msg, enable: Dev.enable, colorInt: 93, isLog: isLog, fileInfo: fileInfo, level: 1000, name: 'logWar');
  }


  /// Red text
  static void logError(String msg, {bool? isLog}) {
    final String fileInfo = Dev.isLogFileInfo ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    DevColorizedLog.logCustom(msg, enable: Dev.enable, colorInt: 91, isLog: isLog, fileInfo: fileInfo, level: 2000, name: 'logErr');
  }
}