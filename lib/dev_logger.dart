/*
 * Author: janlionly (janlionly@gmail.com)
 * Date:   2023-09-21
 */
import 'dart:async';
import 'src/customized_logger.dart';

enum DevLevel {
  logNor,
  logInf,
  logSuc,
  logBlk,
  logWar,
  logErr
}

/// @param static [enable]: whether log msg.
/// @param static [isDebugPrint]: whether the method [Dev.print] printing only on debug mode.
/// @param static [isLogFileLocation]: whether log the location file info.
/// @pararm static [defaultColorInt]: the color int of log text.
class Dev {
  static bool enable = true;
  static bool? isDebugPrint;
  static bool isLogFileLocation = true;
  static int defaultColorInt = 0;
  static Function(String)? customFinalFunc;
  
  /// Default color log
  /// @param[colorInt]: 0 to 107
  /// @param[isLog]: if set to true, the static [enable] is true or not, log anyway.
  static void log(
    String msg, {
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
    bool? execFinalFunc,
    }) {
    int ci = colorInt ?? defaultColorInt;
    final String fileInfo = Dev.isLogFileLocation ? 
    (fileLocation != null ? '($fileLocation): ' : '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ')
     : '';
    DevColorizedLog.logCustom(
      msg,
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
      execFinalFunc: execFinalFunc,
    );
  }
  /// log supportting on multiple consoles
  /// @param[isDebug]: default printing only on debug mode, not set using @param static [isDebugPrint].
  static void print(
    Object? object, {
    DevLevel level = DevLevel.logNor, 
    bool? isLog, 
    String? fileLocation, 
    bool? isDebug, 
    bool? execFinalFunc
    }) {
    final String fileInfo = Dev.isLogFileLocation ? 
    (fileLocation != null ? '($fileLocation): ' : '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ')
     : '';
    String msg = "$object";
    bool? isDbgPrint = isDebug ?? Dev.isDebugPrint;
    var name = level.toString().split('.').last;

    final prefix = isDbgPrint == null || isDbgPrint ? 'dbgPrt' : 'unlPrt';
    name = name.replaceAll('log', prefix);

    DevColorizedLog.logCustom(
      msg,
      enable: Dev.enable,
      isLog: isLog, 
      isMultConsole: true,
      isDebugPrint: isDbgPrint,
      fileInfo: fileInfo,
      name: name,
      execFinalFunc: execFinalFunc,
    );
  }

  /// Execute custom final func with purple text or blue text with mult console 
  static void exe(
    String msg, {
    DevLevel level = DevLevel.logNor, 
    bool? isLog, 
    bool? isMultConsole, 
    bool? isDebug, 
    int? colorInt
    }) {
    final String fileInfo = Dev.isLogFileLocation ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    bool isMult = isMultConsole != null && isMultConsole;
    var name = level.toString().split('.').last;
    bool? isDbgPrint = isDebug ?? Dev.isDebugPrint;

    if (isMult) {
      final prefix = isDbgPrint == null || isDbgPrint ? 'dbgPrt' : 'unlPrt';
      name = name.replaceAll('log', prefix);
    }

    DevColorizedLog.logCustom(
      msg, 
      enable: Dev.enable, 
      colorInt: colorInt ?? 95, 
      isLog: isLog,
      isMultConsole: isMultConsole,
      isDebugPrint: isDbgPrint,
      fileInfo: fileInfo, 
      name: name,
      execFinalFunc: true,
    );
  }
  
  /// Blink orange text
  static void logBlink(String msg, {bool? isLog, bool isSlow = true, bool? execFinalFunc}) {
    final String fileInfo = Dev.isLogFileLocation ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    DevColorizedLog.logCustom(
      msg, 
      enable: Dev.enable, 
      colorInt: isSlow ? 5 : 6, 
      isLog: isLog, 
      fileInfo: fileInfo, 
      name: 'logBlk',
      execFinalFunc: execFinalFunc,
    );
  }


  /// Blue text
  static void logInfo(String msg, {bool? isLog, bool? execFinalFunc}) {
    final String fileInfo = Dev.isLogFileLocation ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    DevColorizedLog.logCustom(
      msg, 
      enable: Dev.enable, 
      colorInt: 96, 
      isLog: isLog, 
      fileInfo: fileInfo, 
      name: 'logInf',
      execFinalFunc: execFinalFunc,
    );
  }


  /// Green text
  static void logSuccess(String msg, {bool? isLog, bool? execFinalFunc}) {
    final String fileInfo = Dev.isLogFileLocation ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    DevColorizedLog.logCustom(
      msg, 
      enable: Dev.enable, 
      colorInt: 92, 
      isLog: isLog, 
      fileInfo: fileInfo, 
      name: 'logSuc',
      execFinalFunc: execFinalFunc,
    );
  }


  /// Yellow text
  static void logWarning(String msg, {bool? isLog, bool? execFinalFunc}) {
    final String fileInfo = Dev.isLogFileLocation ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    DevColorizedLog.logCustom(
      msg, 
      enable: Dev.enable, 
      colorInt: 93, 
      isLog: isLog, 
      fileInfo: fileInfo, 
      level: 1000, 
      name: 'logWar',
      execFinalFunc: execFinalFunc,
    );
  }


  /// Red text
  static void logError(String msg, {bool? isLog, bool? execFinalFunc}) {
    final String fileInfo = Dev.isLogFileLocation ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    DevColorizedLog.logCustom(
      msg, 
      enable: Dev.enable, 
      colorInt: 91, 
      isLog: isLog, 
      fileInfo: fileInfo, 
      level: 2000, 
      name: 'logErr',
      execFinalFunc: execFinalFunc,
    );
  }
}