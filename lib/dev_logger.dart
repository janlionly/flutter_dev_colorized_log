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
  logWar,
  logErr,
  logBlk
}

/// @param static [enable]: whether log msg.
/// @param static [isDebugPrint]: whether the method [Dev.print] printing only on debug mode.
/// @param static [isLogFileLocation]: whether log the location file info.
/// @pararm static [defaultColorInt]: the color int of log text.
class Dev {
  static bool enable = false;
  static bool? isDebugPrint;
  static bool isLogFileLocation = true;
  static int defaultColorInt = 0;
  static Function(String)? customFinalFunc;

  /// whether log the date time
  static bool isLogShowDateTime = true;

   /// whether execFinalFunc with date time
  static bool isExeWithDateTime = false;

  /// whether execFinalFunc with showing log
  static bool isExeWithShowLog = true;

  static final _logColorMap = {
    DevLevel.logNor: defaultColorInt,
    DevLevel.logInf: 96,
    DevLevel.logSuc: 92,
    DevLevel.logWar: 93,
    DevLevel.logErr: 91,
    DevLevel.logBlk: 5,    
  };

  static final _exeColorMap = {
    DevLevel.logNor: 95,
    DevLevel.logInf: 106,
    DevLevel.logSuc: 102,
    DevLevel.logWar: 103,
    DevLevel.logErr: 101,
    DevLevel.logBlk: 6,
  };
  
  /// Default color log
  /// @param[colorInt]: 0 to 107
  /// @param[isLog]: if set to true, the static [enable] is true or not, log anyway.
  static void log(
    String msg, {
    DevLevel level = DevLevel.logNor,
    bool? isLog, 
    int? colorInt,
    String? fileLocation,
    DateTime? time,
    int? sequenceNumber,
    String? name,
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
    bool? execFinalFunc,
    }) {
    int ci = colorInt ?? (_logColorMap[level] ?? defaultColorInt);
    final String fileInfo = Dev.isLogFileLocation ? 
    (fileLocation != null ? '($fileLocation): ' : '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ')
     : '';
    final levelMap = {DevLevel.logWar: 1000, DevLevel.logErr: 2000};
    final theName = name ?? level.toString().split('.').last;

    DevColorizedLog.logCustom(
      msg,
      enable: Dev.enable,
      colorInt: execFinalFunc != null && execFinalFunc ? _exeColorMap[level]! : ci, 
      isLog: isLog, 
      fileInfo: fileInfo,
      time: time,
      sequenceNumber: sequenceNumber,
      level: levelMap[level] ?? 0,
      name: theName,
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
    String? name,
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
    var theName = name ?? level.toString().split('.').last;

    final prefix = isDbgPrint == null || isDbgPrint ? 'dbgPrt' : 'unlPrt';
    theName = theName.replaceAll('log', prefix);

    DevColorizedLog.logCustom(
      msg,
      enable: Dev.enable,
      isLog: isLog, 
      isMultConsole: true,
      isDebugPrint: isDbgPrint,
      fileInfo: fileInfo,
      name: theName,
      execFinalFunc: execFinalFunc,
    );
  }

  /// Execute custom final func with purple text or blue text with mult console 
  static void exe(
    String msg, {
    String? name,
    DevLevel level = DevLevel.logNor, 
    bool? isLog, 
    bool? isMultConsole, 
    bool? isDebug, 
    int? colorInt,
    String? fileInfo
    }) {
    int ci = colorInt ?? (_exeColorMap[level] ?? 95);
    final String theFileInfo = Dev.isLogFileLocation ? (fileInfo ?? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ') : '';
    bool isMult = isMultConsole != null && isMultConsole;
    var theName = name ?? level.toString().split('.').last;
    bool? isDbgPrint = isDebug ?? Dev.isDebugPrint;
    final levelMap = {DevLevel.logWar: 1000, DevLevel.logErr: 2000};

    if (isMult) {
      final prefix = isDbgPrint == null || isDbgPrint ? 'dbgPrt' : 'unlPrt';
      theName = theName.replaceAll('log', prefix);
    }

    DevColorizedLog.logCustom(
      msg, 
      enable: Dev.enable, 
      colorInt: ci, 
      isLog: isLog,
      isMultConsole: isMultConsole,
      isDebugPrint: isDbgPrint,
      fileInfo: theFileInfo, 
      name: theName,
      level: levelMap[level] ?? 0,
      execFinalFunc: true,
    );
  }

  static void exeInfo(
    String msg, {
    bool? isLog, 
    bool? isMultConsole, 
    bool? isDebug,
    }) {
    final String fileInfo = Dev.isLogFileLocation ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    Dev.exe(
      msg, 
      isLog: isLog, 
      isMultConsole: isMultConsole, 
      isDebug: isDebug, 
      fileInfo: fileInfo, 
      colorInt: _exeColorMap[DevLevel.logInf], 
      level: DevLevel.logInf
    );
  }

  static void exeSuccess(
    String msg, {
    bool? isLog, 
    bool? isMultConsole, 
    bool? isDebug, 
    }) {
    final String fileInfo = Dev.isLogFileLocation ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    Dev.exe(
      msg, 
      isLog: isLog, 
      isMultConsole: isMultConsole, 
      isDebug: isDebug, 
      fileInfo: fileInfo, 
      colorInt: _exeColorMap[DevLevel.logSuc], 
      level: DevLevel.logSuc
    );
  }

  static void exeWarning(
    String msg, {
    bool? isLog, 
    bool? isMultConsole, 
    bool? isDebug, 
    }) {
    final String fileInfo = Dev.isLogFileLocation ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    Dev.exe(
      msg, 
      isLog: isLog, 
      isMultConsole: isMultConsole, 
      isDebug: isDebug, 
      fileInfo: fileInfo, 
      colorInt: _exeColorMap[DevLevel.logWar], 
      level: DevLevel.logWar
    );
  }

  static void exeError(
    String msg, {
    bool? isLog, 
    bool? isMultConsole, 
    bool? isDebug, 
    }) {
    final String fileInfo = Dev.isLogFileLocation ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    Dev.exe(
      msg, 
      isLog: isLog, 
      isMultConsole: isMultConsole, 
      isDebug: isDebug, 
      fileInfo: fileInfo, 
      colorInt: _exeColorMap[DevLevel.logErr], 
      level: DevLevel.logErr
    );
  }

  static void exeBlink(
    String msg, {
    bool? isLog, 
    bool? isMultConsole, 
    bool? isDebug, 
    }) {
    final String fileInfo = Dev.isLogFileLocation ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    Dev.exe(
      msg, 
      isLog: isLog, 
      isMultConsole: isMultConsole, 
      isDebug: isDebug, 
      fileInfo: fileInfo, 
      colorInt: _exeColorMap[DevLevel.logBlk], 
      level: DevLevel.logBlk
    );
  }

  /// Blink orange text
  static void logBlink(String msg, {bool? isLog, bool isSlow = true, bool? execFinalFunc}) {
    final String fileInfo = Dev.isLogFileLocation ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ' : '';
    DevColorizedLog.logCustom(
      msg, 
      enable: Dev.enable, 
      colorInt: execFinalFunc != null && execFinalFunc ? 6 : (isSlow ? 5 : 6), 
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
      colorInt: execFinalFunc != null && execFinalFunc ? _exeColorMap[DevLevel.logInf]! : _logColorMap[DevLevel.logInf]!, 
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
      colorInt: execFinalFunc != null && execFinalFunc ? _exeColorMap[DevLevel.logSuc]! : _logColorMap[DevLevel.logSuc]!, 
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
      colorInt: execFinalFunc != null && execFinalFunc ? _exeColorMap[DevLevel.logWar]! : _logColorMap[DevLevel.logWar]!, 
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
      colorInt: execFinalFunc != null && execFinalFunc ? _exeColorMap[DevLevel.logErr]! : _logColorMap[DevLevel.logErr]!, 
      isLog: isLog, 
      fileInfo: fileInfo, 
      level: 2000, 
      name: 'logErr',
      execFinalFunc: execFinalFunc,
    );
  }
}