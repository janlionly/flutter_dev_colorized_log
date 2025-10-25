/*
 * Author: janlionly (janlionly@gmail.com)
 * Date:   2023-09-21
 */
import 'dart:async';
import 'src/customized_logger.dart';

enum DevLevel { logNor, logInf, logSuc, logWar, logErr, logBlk }

/// @param static [enable]: whether log msg.
/// @param static [isDebugPrint]: whether the method [Dev.print] printing only on debug mode.
/// @param static [isLogFileLocation]: whether log the location file info.
/// @pararm static [defaultColorInt]: the color int of log text.
class Dev {
  static bool enable = false;
  static bool? isDebugPrint;
  static bool isLogFileLocation = true;
  static int? defaultColorInt;

  /// Cache for one-time log keywords to prevent duplicate logging
  /// Stores keywords that have been logged once already
  static final Set<String> _cachedKeys = {};

  /// Check if a keyword has been cached (logged once)
  static bool hasCachedKey(String key) {
    return _cachedKeys.contains(key);
  }

  /// Add a keyword to cache
  static void addCachedKey(String key) {
    _cachedKeys.add(key);
  }

  /// Clear all cached keywords
  static void clearCachedKeys() {
    _cachedKeys.clear();
  }

  /// the custom final function to execute when log level meets the threshold
  static Function(String, DevLevel)? exeFinalFunc;

  /// @deprecated Use [exeFinalFunc] instead. This will be removed in future versions.
  @Deprecated('Use exeFinalFunc instead')
  static Function(String, DevLevel)? get customFinalFunc => _customFinalFunc;
  static set customFinalFunc(Function(String, DevLevel)? value) =>
      _customFinalFunc = value;
  static Function(String, DevLevel)? _customFinalFunc;

  /// whether log the date time
  static bool isLogShowDateTime = true;

  /// whether execFinalFunc with date time
  static bool isExeWithDateTime = false;

  /// whether execFinalFunc with showing log
  static bool isExeWithShowLog = true;

  /// whether log with multiple consoles
  static bool isMultConsoleLog = true;

  /// the lowest level threshold to execute the function of customFinalFunc
  static DevLevel exeLevel = DevLevel.logWar;

  /// whether execFinalFunc log with different color
  static bool isExeDiffColor = false;

  static String prefixName = '';

  /// whether replace newline characters and clean up whitespace for better search visibility in console
  static bool isReplaceNewline = false;

  /// the character to replace newline characters with
  static String newlineReplacement = ' | ';

  static Map<DevLevel, int> get _logColorMap => {
        DevLevel.logNor: (defaultColorInt ?? (isMultConsoleLog ? 4 : 0)),
        DevLevel.logInf: 96,
        DevLevel.logSuc: 92,
        DevLevel.logWar: 93,
        DevLevel.logErr: 91,
        DevLevel.logBlk: isMultConsoleLog ? 95 : 5,
      };

  static Map<DevLevel, int> get _exeColorMap => isExeDiffColor
      ? {
          DevLevel.logNor: 44,
          DevLevel.logInf: 46,
          DevLevel.logSuc: 42,
          DevLevel.logWar: 43,
          DevLevel.logErr: 41,
          DevLevel.logBlk: isMultConsoleLog ? 47 : 6,
        }
      : _logColorMap;

  /// Default color log
  /// @param[colorInt]: 0 to 107
  /// @param[isLog]: if set to true, the static [enable] is true or not, log anyway.
  /// @param[printOnceIfContains]: if provided, only prints once when message contains this keyword
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
    String? printOnceIfContains,
  }) {
    int ci = colorInt ??
        (_logColorMap[level] ??
            (defaultColorInt ?? (isMultConsoleLog ? 4 : 0)));
    final String fileInfo = Dev.isLogFileLocation
        ? (fileLocation != null
            ? '($fileLocation): '
            : '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ')
        : '';
    final levelMap = {DevLevel.logWar: 1000, DevLevel.logErr: 2000};
    final theName = name ?? level.toString().split('.').last;

    DevColorizedLog.logCustom(
      msg,
      devLevel: level,
      enable: Dev.enable,
      colorInt:
          execFinalFunc != null && execFinalFunc ? _exeColorMap[level]! : ci,
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
      printOnceIfContains: printOnceIfContains,
    );
  }

  /// log supportting on multiple consoles
  /// @param[isDebug]: default printing only on debug mode, not set using @param static [isDebugPrint].
  /// @param[printOnceIfContains]: if provided, only prints once when message contains this keyword
  static void print(Object? object,
      {String? name,
      DevLevel level = DevLevel.logNor,
      int? colorInt,
      bool? isLog,
      String? fileLocation,
      bool? isDebug,
      bool? execFinalFunc,
      Object? error,
      StackTrace? stackTrace,
      String? printOnceIfContains}) {
    final String fileInfo = Dev.isLogFileLocation
        ? (fileLocation != null
            ? '($fileLocation): '
            : '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ')
        : '';
    int ci = colorInt ??
        (_logColorMap[level] ??
            (defaultColorInt ?? (isMultConsoleLog ? 4 : 0)));
    String msg = "$object";
    bool? isDbgPrint = isDebug ?? Dev.isDebugPrint;
    var theName = name ?? level.toString().split('.').last;

    final prefix = isDbgPrint == null || isDbgPrint ? 'dbgPrt' : 'unlPrt';
    theName = theName.replaceAll('log', prefix);

    DevColorizedLog.logCustom(
      msg,
      devLevel: level,
      enable: Dev.enable,
      colorInt:
          execFinalFunc != null && execFinalFunc ? _exeColorMap[level]! : ci,
      isLog: isLog,
      isMultConsole: true,
      isDebugPrint: isDbgPrint,
      fileInfo: fileInfo,
      name: theName,
      error: error,
      stackTrace: stackTrace,
      execFinalFunc: execFinalFunc,
      printOnceIfContains: printOnceIfContains,
    );
  }

  /// Execute custom final func with purple text or blue text with mult console
  /// @param[printOnceIfContains]: if provided, only prints once when message contains this keyword
  static void exe(String msg,
      {String? name,
      DevLevel level = DevLevel.logNor,
      bool? isLog,
      bool? isMultConsole,
      bool? isDebug,
      int? colorInt,
      String? fileInfo,
      Object? error,
      StackTrace? stackTrace,
      String? printOnceIfContains}) {
    int ci = colorInt ?? (_exeColorMap[level] ?? 44);
    final String theFileInfo = Dev.isLogFileLocation
        ? (fileInfo ??
            '(${StackTrace.current.toString().split('\n')[1].split('/').last}: ')
        : '';
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
      devLevel: level,
      enable: Dev.enable,
      colorInt: ci,
      isLog: isLog,
      isMultConsole: isMultConsole,
      isDebugPrint: isDbgPrint,
      fileInfo: theFileInfo,
      name: theName,
      level: levelMap[level] ?? 0,
      execFinalFunc: true,
      error: error,
      stackTrace: stackTrace,
      printOnceIfContains: printOnceIfContains,
    );
  }

  static void exeInfo(
    String msg, {
    bool? isLog,
    bool? isMultConsole,
    bool? isDebug,
    int? colorInt,
    String? printOnceIfContains,
  }) {
    final String fileInfo = Dev.isLogFileLocation
        ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: '
        : '';
    Dev.exe(msg,
        isLog: isLog,
        isMultConsole: isMultConsole,
        isDebug: isDebug,
        fileInfo: fileInfo,
        colorInt: colorInt ?? _exeColorMap[DevLevel.logInf],
        level: DevLevel.logInf,
        printOnceIfContains: printOnceIfContains);
  }

  static void exeSuccess(
    String msg, {
    bool? isLog,
    bool? isMultConsole,
    bool? isDebug,
    int? colorInt,
    String? printOnceIfContains,
  }) {
    final String fileInfo = Dev.isLogFileLocation
        ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: '
        : '';
    Dev.exe(msg,
        isLog: isLog,
        isMultConsole: isMultConsole,
        isDebug: isDebug,
        fileInfo: fileInfo,
        colorInt: colorInt ?? _exeColorMap[DevLevel.logSuc],
        level: DevLevel.logSuc,
        printOnceIfContains: printOnceIfContains);
  }

  static void exeWarning(
    String msg, {
    bool? isLog,
    bool? isMultConsole,
    bool? isDebug,
    int? colorInt,
    String? printOnceIfContains,
  }) {
    final String fileInfo = Dev.isLogFileLocation
        ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: '
        : '';
    Dev.exe(msg,
        isLog: isLog,
        isMultConsole: isMultConsole,
        isDebug: isDebug,
        fileInfo: fileInfo,
        colorInt: colorInt ?? _exeColorMap[DevLevel.logWar],
        level: DevLevel.logWar,
        printOnceIfContains: printOnceIfContains);
  }

  static void exeError(
    String msg, {
    bool? isLog,
    bool? isMultConsole,
    bool? isDebug,
    int? colorInt,
    Object? error,
    StackTrace? stackTrace,
    String? printOnceIfContains,
  }) {
    final String fileInfo = Dev.isLogFileLocation
        ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: '
        : '';
    Dev.exe(msg,
        isLog: isLog,
        isMultConsole: isMultConsole,
        isDebug: isDebug,
        fileInfo: fileInfo,
        colorInt: colorInt ?? _exeColorMap[DevLevel.logErr],
        level: DevLevel.logErr,
        error: error,
        stackTrace: stackTrace,
        printOnceIfContains: printOnceIfContains);
  }

  static void exeBlink(
    String msg, {
    bool? isLog,
    bool? isMultConsole,
    bool? isDebug,
    int? colorInt,
    String? printOnceIfContains,
  }) {
    final String fileInfo = Dev.isLogFileLocation
        ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: '
        : '';
    Dev.exe(msg,
        isLog: isLog,
        isMultConsole: isMultConsole,
        isDebug: isDebug,
        fileInfo: fileInfo,
        colorInt: colorInt ?? _exeColorMap[DevLevel.logBlk],
        level: DevLevel.logBlk,
        printOnceIfContains: printOnceIfContains);
  }

  /// Blink orange text
  static void logBlink(String msg,
      {bool? isLog, bool? execFinalFunc, String? printOnceIfContains}) {
    final String fileInfo = Dev.isLogFileLocation
        ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: '
        : '';
    DevColorizedLog.logCustom(
      msg,
      devLevel: DevLevel.logBlk,
      enable: Dev.enable,
      colorInt: execFinalFunc != null && execFinalFunc
          ? _exeColorMap[DevLevel.logBlk]!
          : _logColorMap[DevLevel.logBlk]!,
      isLog: isLog,
      fileInfo: fileInfo,
      name: 'logBlk',
      execFinalFunc: execFinalFunc,
      printOnceIfContains: printOnceIfContains,
    );
  }

  /// Blue text
  static void logInfo(String msg,
      {bool? isLog, bool? execFinalFunc, String? printOnceIfContains}) {
    final String fileInfo = Dev.isLogFileLocation
        ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: '
        : '';
    DevColorizedLog.logCustom(
      msg,
      devLevel: DevLevel.logInf,
      enable: Dev.enable,
      colorInt: execFinalFunc != null && execFinalFunc
          ? _exeColorMap[DevLevel.logInf]!
          : _logColorMap[DevLevel.logInf]!,
      isLog: isLog,
      fileInfo: fileInfo,
      name: 'logInf',
      execFinalFunc: execFinalFunc,
      printOnceIfContains: printOnceIfContains,
    );
  }

  /// Green text
  static void logSuccess(String msg,
      {bool? isLog, bool? execFinalFunc, String? printOnceIfContains}) {
    final String fileInfo = Dev.isLogFileLocation
        ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: '
        : '';
    DevColorizedLog.logCustom(
      msg,
      devLevel: DevLevel.logSuc,
      enable: Dev.enable,
      colorInt: execFinalFunc != null && execFinalFunc
          ? _exeColorMap[DevLevel.logSuc]!
          : _logColorMap[DevLevel.logSuc]!,
      isLog: isLog,
      fileInfo: fileInfo,
      name: 'logSuc',
      execFinalFunc: execFinalFunc,
      printOnceIfContains: printOnceIfContains,
    );
  }

  /// Yellow text
  static void logWarning(String msg,
      {bool? isLog, bool? execFinalFunc, String? printOnceIfContains}) {
    final String fileInfo = Dev.isLogFileLocation
        ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: '
        : '';
    DevColorizedLog.logCustom(
      msg,
      devLevel: DevLevel.logWar,
      enable: Dev.enable,
      colorInt: execFinalFunc != null && execFinalFunc
          ? _exeColorMap[DevLevel.logWar]!
          : _logColorMap[DevLevel.logWar]!,
      isLog: isLog,
      fileInfo: fileInfo,
      level: 1000,
      name: 'logWar',
      execFinalFunc: execFinalFunc,
      printOnceIfContains: printOnceIfContains,
    );
  }

  /// Red text
  static void logError(String msg,
      {bool? isLog,
      bool? execFinalFunc,
      Object? error,
      StackTrace? stackTrace,
      String? printOnceIfContains}) {
    final String fileInfo = Dev.isLogFileLocation
        ? '(${StackTrace.current.toString().split('\n')[1].split('/').last}: '
        : '';
    DevColorizedLog.logCustom(
      msg,
      devLevel: DevLevel.logErr,
      enable: Dev.enable,
      colorInt: execFinalFunc != null && execFinalFunc
          ? _exeColorMap[DevLevel.logErr]!
          : _logColorMap[DevLevel.logErr]!,
      isLog: isLog,
      fileInfo: fileInfo,
      level: 2000,
      name: 'logErr',
      execFinalFunc: execFinalFunc,
      error: error,
      stackTrace: stackTrace,
      printOnceIfContains: printOnceIfContains,
    );
  }
}
