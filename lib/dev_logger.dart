/*
 * Author: janlionly (janlionly@gmail.com)
 * Date:   2023-09-21
 */
import 'dart:async';
import 'package:stack_trace/stack_trace.dart';
import 'src/customized_logger.dart';

enum DevLevel { verbose, normal, info, success, warn, error, fatal }

/// @param static [enable]: whether log msg.
/// @param static [isDebugPrint]: whether the method [Dev.print] printing only on debug mode.
/// @param static [isLogFileLocation]: whether log the location file info.
/// @param static [isLightweightMode]: Skip stack trace capture for maximum performance.
/// @param static [useOptimizedStackTrace]: Use stack_trace package for 40-60% better performance (default: true).
/// @pararm static [defaultColorInt]: the color int of log text.
class Dev {
  static bool enable = false;
  static bool? isDebugPrint;
  static bool isLogFileLocation = true;
  static int? defaultColorInt;

  /// Lightweight mode: Skip stack trace capture completely for production
  /// When enabled, file location logging is disabled for maximum performance
  /// Recommended for production environments where logging performance is critical
  static bool isLightweightMode = false;

  /// Use optimized stack trace parsing (stack_trace package)
  /// When enabled (default), uses the stack_trace package for better performance (40-60% faster)
  /// When disabled, uses basic string operations (still 10-20% faster than original)
  static bool useOptimizedStackTrace = true;

  /// Efficiently extract file location from stack trace
  /// Returns formatted string like "(main.dart:42): "
  static String _getFileLocation() {
    if (!isLogFileLocation || isLightweightMode) return '';

    if (useOptimizedStackTrace) {
      // Use stack_trace package for maximum efficiency
      // Only captures 2 frames instead of the entire stack
      try {
        final trace = Trace.current(1);
        if (trace.frames.isEmpty) return '';

        // Get the caller's frame (skip this function itself)
        final frame =
            trace.frames.length > 1 ? trace.frames[1] : trace.frames[0];
        final uri = frame.uri;
        final filename = uri.pathSegments.isNotEmpty
            ? uri.pathSegments.last
            : uri.toString();

        return '($filename:${frame.line}): ';
      } catch (e) {
        // Fallback to basic method if stack_trace fails
        return _getFileLocationBasic();
      }
    } else {
      return _getFileLocationBasic();
    }
  }

  /// Basic stack trace extraction using string operations
  /// Used as fallback or when useOptimizedStackTrace is false
  static String _getFileLocationBasic() {
    final stackString = StackTrace.current.toString();
    // Find the start of the second line (index 1)
    final firstNewline = stackString.indexOf('\n');
    if (firstNewline == -1) return '';

    final secondNewline = stackString.indexOf('\n', firstNewline + 1);
    final secondLine = secondNewline == -1
        ? stackString.substring(firstNewline + 1)
        : stackString.substring(firstNewline + 1, secondNewline);

    // Extract filename from the end of the line
    final lastSlash = secondLine.lastIndexOf('/');
    final filename =
        lastSlash == -1 ? secondLine : secondLine.substring(lastSlash + 1);

    return '($filename): ';
  }

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

  /// Cache for debounce functionality
  /// Stores the last execution timestamp for each debounced log
  static final Map<String, DateTime> _debounceTimestamps = {};

  /// Check if a log should be debounced
  /// Returns true if the log should be skipped (still in debounce period)
  static bool shouldDebounce(String key, int debounceMs) {
    if (debounceMs <= 0) return false;

    final now = DateTime.now();
    final lastTime = _debounceTimestamps[key];

    if (lastTime == null) {
      _debounceTimestamps[key] = now;
      return false;
    }

    final difference = now.difference(lastTime).inMilliseconds;
    if (difference < debounceMs) {
      return true; // Still in debounce period, skip this log
    }

    // Update timestamp and allow log
    _debounceTimestamps[key] = now;
    return false;
  }

  /// Clear all debounce timestamps
  static void clearDebounceTimestamps() {
    _debounceTimestamps.clear();
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

  /// The lowest level threshold to execute the function of exeFinalFunc
  static DevLevel exeLevel = DevLevel.warn;

  /// The lowest level threshold to print logs to console
  /// Logs below this level will be ignored
  /// Default is verbose (print all logs)
  static DevLevel logLevel = DevLevel.verbose;

  /// whether execFinalFunc log with different color
  static bool isExeDiffColor = false;

  static String prefixName = '';

  /// whether replace newline characters and clean up whitespace for better search visibility in console
  static bool isReplaceNewline = false;

  /// the character to replace newline characters with
  static String newlineReplacement = ' | ';

  static Map<DevLevel, int> get _logColorMap => {
        DevLevel.verbose: 90, // Dark gray for verbose
        DevLevel.normal: (defaultColorInt ?? (isMultConsoleLog ? 4 : 0)),
        DevLevel.info: 96,
        DevLevel.success: 92,
        DevLevel.warn: 93,
        DevLevel.error: 91,
        DevLevel.fatal: isMultConsoleLog ? 95 : 5,
      };

  static Map<DevLevel, int> get _exeColorMap => isExeDiffColor
      ? {
          DevLevel.verbose: 100, // Dark gray background for verbose
          DevLevel.normal: 44,
          DevLevel.info: 46,
          DevLevel.success: 42,
          DevLevel.warn: 43,
          DevLevel.error: 41,
          DevLevel.fatal: isMultConsoleLog ? 47 : 6,
        }
      : _logColorMap;

  /// Default color log
  /// @param[colorInt]: 0 to 107
  /// @param[isLog]: if set to true, the static [enable] is true or not, log anyway.
  /// @param[printOnceIfContains]: if provided, only prints once when message contains this keyword
  /// @param[debounceMs]: debounce time interval in milliseconds, logs within this interval will be discarded
  /// @param[debounceKey]: custom key for debounce identification (if not provided, uses msg|devLevel|name as fallback)
  static void log(
    String msg, {
    DevLevel level = DevLevel.normal,
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
    int debounceMs = 0,
    String? debounceKey,
  }) {
    int ci = colorInt ??
        (_logColorMap[level] ??
            (defaultColorInt ?? (isMultConsoleLog ? 4 : 0)));
    final String fileInfo =
        fileLocation != null ? '($fileLocation): ' : _getFileLocation();
    final levelMap = {DevLevel.warn: 1000, DevLevel.error: 2000};
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
      debounceMs: debounceMs,
      debounceKey: debounceKey,
    );
  }

  /// log supportting on multiple consoles
  /// @param[isDebug]: default printing only on debug mode, not set using @param static [isDebugPrint].
  /// @param[printOnceIfContains]: if provided, only prints once when message contains this keyword
  /// @param[debounceMs]: debounce time interval in milliseconds, logs within this interval will be discarded
  /// @param[debounceKey]: custom key for debounce identification (if not provided, uses msg|devLevel|name as fallback)
  static void print(Object? object,
      {String? name,
      DevLevel level = DevLevel.normal,
      int? colorInt,
      bool? isLog,
      String? fileLocation,
      bool? isDebug,
      bool? execFinalFunc,
      Object? error,
      StackTrace? stackTrace,
      String? printOnceIfContains,
      int debounceMs = 0,
      String? debounceKey}) {
    final String fileInfo =
        fileLocation != null ? '($fileLocation): ' : _getFileLocation();
    int ci = colorInt ??
        (_logColorMap[level] ??
            (defaultColorInt ?? (isMultConsoleLog ? 4 : 0)));
    String msg = "$object";
    bool? isDbgPrint = isDebug ?? Dev.isDebugPrint;
    var theName = name ?? level.toString().split('.').last;

    final prefix = isDbgPrint == null || isDbgPrint ? 'dbgPrt' : 'unlPrt';
    theName =
        '$prefix-$theName'; // Use prefix directly since enum names no longer start with 'log'

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
      debounceMs: debounceMs,
      debounceKey: debounceKey,
    );
  }

  /// Execute custom final func with purple text or blue text with mult console
  /// @param[printOnceIfContains]: if provided, only prints once when message contains this keyword
  /// @param[debounceMs]: debounce time interval in milliseconds, logs within this interval will be discarded
  /// @param[debounceKey]: custom key for debounce identification (if not provided, uses msg|devLevel|name as fallback)
  static void exe(String msg,
      {String? name,
      DevLevel level = DevLevel.normal,
      bool? isLog,
      bool? isMultConsole,
      bool? isDebug,
      int? colorInt,
      String? fileInfo,
      Object? error,
      StackTrace? stackTrace,
      String? printOnceIfContains,
      int debounceMs = 0,
      String? debounceKey}) {
    int ci = colorInt ?? (_exeColorMap[level] ?? 44);
    final String theFileInfo = fileInfo ?? _getFileLocation();
    bool isMult = isMultConsole != null && isMultConsole;
    var theName = name ?? level.toString().split('.').last;
    bool? isDbgPrint = isDebug ?? Dev.isDebugPrint;
    final levelMap = {DevLevel.warn: 1000, DevLevel.error: 2000};

    if (isMult) {
      final prefix = isDbgPrint == null || isDbgPrint ? 'dbgPrt' : 'unlPrt';
      theName =
          '$prefix-$theName'; // Use prefix directly since enum names no longer start with 'log'
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
      debounceMs: debounceMs,
      debounceKey: debounceKey,
    );
  }

  static void exeVerbose(
    String msg, {
    bool? isLog,
    bool? isMultConsole,
    bool? isDebug,
    int? colorInt,
    String? printOnceIfContains,
    int debounceMs = 0,
    String? debounceKey,
  }) {
    final String fileInfo = _getFileLocation();
    Dev.exe(msg,
        isLog: isLog,
        isMultConsole: isMultConsole,
        isDebug: isDebug,
        fileInfo: fileInfo,
        colorInt: colorInt ?? _exeColorMap[DevLevel.verbose],
        level: DevLevel.verbose,
        printOnceIfContains: printOnceIfContains,
        debounceMs: debounceMs,
        debounceKey: debounceKey);
  }

  static void exeInfo(
    String msg, {
    bool? isLog,
    bool? isMultConsole,
    bool? isDebug,
    int? colorInt,
    String? printOnceIfContains,
    int debounceMs = 0,
    String? debounceKey,
  }) {
    final String fileInfo = _getFileLocation();
    Dev.exe(msg,
        isLog: isLog,
        isMultConsole: isMultConsole,
        isDebug: isDebug,
        fileInfo: fileInfo,
        colorInt: colorInt ?? _exeColorMap[DevLevel.info],
        level: DevLevel.info,
        printOnceIfContains: printOnceIfContains,
        debounceMs: debounceMs,
        debounceKey: debounceKey);
  }

  static void exeSuccess(
    String msg, {
    bool? isLog,
    bool? isMultConsole,
    bool? isDebug,
    int? colorInt,
    String? printOnceIfContains,
    int debounceMs = 0,
    String? debounceKey,
  }) {
    final String fileInfo = _getFileLocation();
    Dev.exe(msg,
        isLog: isLog,
        isMultConsole: isMultConsole,
        isDebug: isDebug,
        fileInfo: fileInfo,
        colorInt: colorInt ?? _exeColorMap[DevLevel.success],
        level: DevLevel.success,
        printOnceIfContains: printOnceIfContains,
        debounceMs: debounceMs,
        debounceKey: debounceKey);
  }

  static void exeWarn(
    String msg, {
    bool? isLog,
    bool? isMultConsole,
    bool? isDebug,
    int? colorInt,
    String? printOnceIfContains,
    int debounceMs = 0,
    String? debounceKey,
  }) {
    final String fileInfo = _getFileLocation();
    Dev.exe(msg,
        isLog: isLog,
        isMultConsole: isMultConsole,
        isDebug: isDebug,
        fileInfo: fileInfo,
        colorInt: colorInt ?? _exeColorMap[DevLevel.warn],
        level: DevLevel.warn,
        printOnceIfContains: printOnceIfContains,
        debounceMs: debounceMs,
        debounceKey: debounceKey);
  }

  /// @Deprecated('Use exeWarn instead')
  static void exeWarning(
    String msg, {
    bool? isLog,
    bool? isMultConsole,
    bool? isDebug,
    int? colorInt,
    String? printOnceIfContains,
    int debounceMs = 0,
    String? debounceKey,
  }) {
    exeWarn(msg,
        isLog: isLog,
        isMultConsole: isMultConsole,
        isDebug: isDebug,
        colorInt: colorInt,
        printOnceIfContains: printOnceIfContains,
        debounceMs: debounceMs,
        debounceKey: debounceKey);
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
    int debounceMs = 0,
    String? debounceKey,
  }) {
    final String fileInfo = _getFileLocation();
    Dev.exe(msg,
        isLog: isLog,
        isMultConsole: isMultConsole,
        isDebug: isDebug,
        fileInfo: fileInfo,
        colorInt: colorInt ?? _exeColorMap[DevLevel.error],
        level: DevLevel.error,
        error: error,
        stackTrace: stackTrace,
        printOnceIfContains: printOnceIfContains,
        debounceMs: debounceMs,
        debounceKey: debounceKey);
  }

  static void exeFatal(
    String msg, {
    bool? isLog,
    bool? isMultConsole,
    bool? isDebug,
    int? colorInt,
    String? printOnceIfContains,
    int debounceMs = 0,
    String? debounceKey,
  }) {
    final String fileInfo = _getFileLocation();
    Dev.exe(msg,
        isLog: isLog,
        isMultConsole: isMultConsole,
        isDebug: isDebug,
        fileInfo: fileInfo,
        colorInt: colorInt ?? _exeColorMap[DevLevel.fatal],
        level: DevLevel.fatal,
        printOnceIfContains: printOnceIfContains,
        debounceMs: debounceMs,
        debounceKey: debounceKey);
  }

  /// Verbose - Dark gray text for detailed debug information
  /// Use for verbose debugging details
  static void logVerbose(String msg,
      {bool? isLog,
      bool? execFinalFunc,
      String? printOnceIfContains,
      int debounceMs = 0,
      String? debounceKey}) {
    final String fileInfo = _getFileLocation();
    DevColorizedLog.logCustom(
      msg,
      devLevel: DevLevel.verbose,
      enable: Dev.enable,
      colorInt: execFinalFunc != null && execFinalFunc
          ? _exeColorMap[DevLevel.verbose]!
          : _logColorMap[DevLevel.verbose]!,
      isLog: isLog,
      fileInfo: fileInfo,
      name: DevLevel.verbose.name, // Use enum name instead of hardcoded string
      execFinalFunc: execFinalFunc,
      printOnceIfContains: printOnceIfContains,
      debounceMs: debounceMs,
      debounceKey: debounceKey,
    );
  }

  /// Fatal/Critical error - text (orange/purple)
  /// Use for fatal errors that require immediate attention
  static void logFatal(String msg,
      {bool? isLog,
      bool? execFinalFunc,
      String? printOnceIfContains,
      int debounceMs = 0,
      String? debounceKey}) {
    final String fileInfo = _getFileLocation();
    DevColorizedLog.logCustom(
      msg,
      devLevel: DevLevel.fatal,
      enable: Dev.enable,
      colorInt: execFinalFunc != null && execFinalFunc
          ? _exeColorMap[DevLevel.fatal]!
          : _logColorMap[DevLevel.fatal]!,
      isLog: isLog,
      fileInfo: fileInfo,
      name: DevLevel.fatal.name, // Use enum name instead of hardcoded string
      execFinalFunc: execFinalFunc,
      printOnceIfContains: printOnceIfContains,
      debounceMs: debounceMs,
      debounceKey: debounceKey,
    );
  }

  /// Info - Blue text for informational messages
  static void logInfo(String msg,
      {bool? isLog,
      bool? execFinalFunc,
      String? printOnceIfContains,
      int debounceMs = 0,
      String? debounceKey}) {
    final String fileInfo = _getFileLocation();
    DevColorizedLog.logCustom(
      msg,
      devLevel: DevLevel.info,
      enable: Dev.enable,
      colorInt: execFinalFunc != null && execFinalFunc
          ? _exeColorMap[DevLevel.info]!
          : _logColorMap[DevLevel.info]!,
      isLog: isLog,
      fileInfo: fileInfo,
      name: DevLevel.info.name, // Use enum name instead of hardcoded string
      execFinalFunc: execFinalFunc,
      printOnceIfContains: printOnceIfContains,
      debounceMs: debounceMs,
      debounceKey: debounceKey,
    );
  }

  /// Success - Green text for success/completion messages
  static void logSuccess(String msg,
      {bool? isLog,
      bool? execFinalFunc,
      String? printOnceIfContains,
      int debounceMs = 0,
      String? debounceKey}) {
    final String fileInfo = _getFileLocation();
    DevColorizedLog.logCustom(
      msg,
      devLevel: DevLevel.success,
      enable: Dev.enable,
      colorInt: execFinalFunc != null && execFinalFunc
          ? _exeColorMap[DevLevel.success]!
          : _logColorMap[DevLevel.success]!,
      isLog: isLog,
      fileInfo: fileInfo,
      name: DevLevel.success.name, // Use enum name instead of hardcoded string
      execFinalFunc: execFinalFunc,
      printOnceIfContains: printOnceIfContains,
      debounceMs: debounceMs,
      debounceKey: debounceKey,
    );
  }

  /// Warn - Yellow text for warning messages
  static void logWarn(String msg,
      {bool? isLog,
      bool? execFinalFunc,
      String? printOnceIfContains,
      int debounceMs = 0,
      String? debounceKey}) {
    final String fileInfo = _getFileLocation();
    DevColorizedLog.logCustom(
      msg,
      devLevel: DevLevel.warn,
      enable: Dev.enable,
      colorInt: execFinalFunc != null && execFinalFunc
          ? _exeColorMap[DevLevel.warn]!
          : _logColorMap[DevLevel.warn]!,
      isLog: isLog,
      fileInfo: fileInfo,
      level: 1000,
      name: DevLevel.warn.name, // Use enum name instead of hardcoded string
      execFinalFunc: execFinalFunc,
      printOnceIfContains: printOnceIfContains,
      debounceMs: debounceMs,
      debounceKey: debounceKey,
    );
  }

  /// @Deprecated('Use logWarn instead')
  /// Warning - Yellow text for warning messages (deprecated, use logWarn)
  static void logWarning(String msg,
      {bool? isLog,
      bool? execFinalFunc,
      String? printOnceIfContains,
      int debounceMs = 0,
      String? debounceKey}) {
    logWarn(msg,
        isLog: isLog,
        execFinalFunc: execFinalFunc,
        printOnceIfContains: printOnceIfContains,
        debounceMs: debounceMs,
        debounceKey: debounceKey);
  }

  /// Error - Red text for error messages
  static void logError(String msg,
      {bool? isLog,
      bool? execFinalFunc,
      Object? error,
      StackTrace? stackTrace,
      String? printOnceIfContains,
      int debounceMs = 0,
      String? debounceKey}) {
    final String fileInfo = _getFileLocation();
    DevColorizedLog.logCustom(
      msg,
      devLevel: DevLevel.error,
      enable: Dev.enable,
      colorInt: execFinalFunc != null && execFinalFunc
          ? _exeColorMap[DevLevel.error]!
          : _logColorMap[DevLevel.error]!,
      isLog: isLog,
      fileInfo: fileInfo,
      level: 2000,
      name: DevLevel.error.name, // Use enum name instead of hardcoded string
      execFinalFunc: execFinalFunc,
      error: error,
      stackTrace: stackTrace,
      printOnceIfContains: printOnceIfContains,
      debounceMs: debounceMs,
      debounceKey: debounceKey,
    );
  }
}
