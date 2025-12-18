/*
 * Author: janlionly (janlionly@gmail.com)
 * Date:   2023-09-21
 */
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:stack_trace/stack_trace.dart';
import 'src/customized_logger.dart';

/// Log level enumeration to categorize the severity of log messages
/// - verbose: Detailed debug information (dark gray)
/// - normal: Standard log messages (default color)
/// - info: Informational messages (blue/cyan)
/// - success: Success/completion messages (green)
/// - warn: Warning messages (yellow)
/// - error: Error messages (red)
/// - fatal: Critical/fatal errors requiring immediate attention (orange/purple)
enum DevLevel { verbose, normal, info, success, warn, error, fatal }

/// Dev - A flexible and colorized logging utility for Flutter/Dart development
///
/// This class provides various logging methods with customizable colors, levels,
/// and advanced features like debouncing, one-time printing, and custom final functions.
///
/// Configuration properties:
/// - [enable]: Global switch to enable/disable all logging
/// - [isDebugPrint]: Whether [Dev.print] method prints only in debug mode
/// - [isLogFileLocation]: Whether to log file location information
/// - [isLightweightMode]: Skip stack trace capture for maximum performance
/// - [useOptimizedStackTrace]: Use stack_trace package for 40-60% better performance (default: true)
/// - [defaultColorInt]: Default ANSI color code (0-107) for log text
/// - [prefixName]: Prefix string prepended to all log messages
/// - [isLogShowDateTime]: Whether to display timestamp in logs
/// - [isMultConsoleLog]: Whether to use multi-console logging mode
/// - [logLevel]: Minimum log level threshold for console output
/// - [exeLevel]: Minimum log level threshold for executing [exeFinalFunc]
/// - [exeFinalFunc]: Custom callback function executed when log level meets threshold
/// - [isExeWithDateTime]: Whether to include timestamp when executing final function
/// - [isExeWithShowLog]: Whether to show log when executing final function
/// - [isExeDiffColor]: Whether to use different colors for final function execution
/// - [isReplaceNewline]: Whether to replace newline characters for better console visibility
/// - [newlineReplacement]: Replacement string for newline characters
class Dev {
  /// Global switch to enable or disable all logging
  /// When false, logs are suppressed unless overridden by individual log calls with isLog: true
  static bool enable = false;

  /// Controls whether [Dev.print] method prints only in debug mode
  /// If null, prints in all modes; if true, prints only in debug mode; if false, prints in all modes
  static bool? isDebugPrint;

  /// Whether to log file location information in the output
  /// When true, logs include file name and line number like "(main.dart:42):"
  static bool isLogFileLocation = true;

  /// Default ANSI color code (0-107) for log text
  /// If not specified, uses default colors based on log level
  static int? defaultColorInt;

  /// Lightweight mode: Skip stack trace capture completely for production
  /// When enabled, file location logging is disabled for maximum performance
  /// Recommended for production environments where logging performance is critical
  static bool isLightweightMode = false;

  /// Use optimized stack trace parsing (stack_trace package)
  /// When enabled (default), uses the stack_trace package for better performance (40-60% faster)
  /// When disabled, uses basic string operations (still 10-20% faster than original)
  static bool useOptimizedStackTrace = true;

  /// Use fast print mode for better performance in multi-console logging
  /// When true, uses print() instead of debugPrint() for faster output
  /// When false, uses debugPrint() which is safer but slower
  ///
  /// Defaults to true in debug mode (kDebugMode) for faster feedback,
  /// and false in release mode for safer logging
  ///
  /// Note: debugPrint throttles output (~800 chars at a time) to prevent log loss,
  /// while print is faster but may lose logs if output is too frequent
  ///
  /// Recommendation:
  /// - Development: true (default in debug mode) for faster feedback
  /// - Production/Testing: false (default in release mode) for safer logging
  static bool useFastPrint = kDebugMode;

  /// Extract tag from file path
  /// Searches for directory names in the file path that match any tag in [tags] set
  /// Returns the first matching tag found, or null if no match
  static String? _extractTagFromUri(Uri uri) {
    if (tags == null || tags!.isEmpty) return null;

    // Get all path segments (directories in the path)
    final pathSegments = uri.pathSegments;

    // Search for any segment that matches a tag
    for (final segment in pathSegments) {
      if (tags!.contains(segment)) {
        return segment;
      }
    }

    return null;
  }

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

  /// Extract tag from stack trace
  /// Returns the auto-detected tag from file path, or null if no match
  static String? _getTagFromStackTrace() {
    // Early return if tags is not configured or empty to avoid unnecessary stack trace capture
    if (tags == null || tags!.isEmpty) return null;

    if (isLightweightMode) return null;

    if (useOptimizedStackTrace) {
      try {
        final trace = Trace.current(1);
        if (trace.frames.isEmpty) return null;

        final frame =
            trace.frames.length > 1 ? trace.frames[1] : trace.frames[0];
        return _extractTagFromUri(frame.uri);
      } catch (e) {
        return null;
      }
    }

    return null;
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
  /// @param[key]: The keyword to check in the cache
  /// @return: Returns true if the keyword has been logged before, false otherwise
  /// Used with [printOnceIfContains] parameter to prevent duplicate log messages
  static bool hasCachedKey(String key) {
    return _cachedKeys.contains(key);
  }

  /// Add a keyword to the cache to mark it as logged
  /// @param[key]: The keyword to add to the cache
  /// After adding, subsequent logs containing this keyword will be suppressed when using [printOnceIfContains]
  static void addCachedKey(String key) {
    _cachedKeys.add(key);
  }

  /// Clear all cached keywords to allow repeated logging
  /// Removes all entries from the one-time print cache
  /// Useful for resetting the print-once state during testing or at application restart
  static void clearCachedKeys() {
    _cachedKeys.clear();
  }

  /// Cache for debounce functionality
  /// Stores the last execution timestamp for each debounced log
  static final Map<String, DateTime> _debounceTimestamps = {};

  /// Check if a log should be debounced based on time interval
  /// @param[key]: The debounce key to identify the log entry
  /// @param[debounceMs]: Debounce interval in milliseconds
  /// @return: Returns true if the log should be skipped (still in debounce period), false to allow logging
  ///
  /// This prevents rapid-fire logging of the same message by enforcing a minimum time interval
  /// between consecutive logs with the same key
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

  /// Clear all debounce timestamps to reset debounce state
  /// Removes all entries from the debounce cache, allowing all debounced logs to fire immediately
  /// Useful for resetting the debounce state during testing or at application restart
  static void clearDebounceTimestamps() {
    _debounceTimestamps.clear();
  }

  /// Custom final function to execute when log level meets the threshold specified by [exeLevel]
  /// Takes two parameters: the log message string and the DevLevel
  /// Useful for custom log processing, remote logging, or error reporting
  static Function(String, DevLevel)? exeFinalFunc;

  /// @deprecated Use [exeFinalFunc] instead. This will be removed in future versions.
  @Deprecated('Use exeFinalFunc instead')
  static Function(String, DevLevel)? get customFinalFunc => _customFinalFunc;
  static set customFinalFunc(Function(String, DevLevel)? value) =>
      _customFinalFunc = value;
  static Function(String, DevLevel)? _customFinalFunc;

  /// Whether to display timestamp in log output
  /// When true, logs include date and time information
  static bool isLogShowDateTime = true;

  /// Whether to include timestamp when executing the final function [exeFinalFunc]
  /// When true, timestamp is passed to the final function
  static bool isExeWithDateTime = false;

  /// Whether to show log output when executing the final function [exeFinalFunc]
  /// When true, logs are displayed in console even when final function is executed
  static bool isExeWithShowLog = true;

  /// Whether to use multi-console logging mode
  /// When true, uses enhanced formatting suitable for multiple console outputs
  static bool isMultConsoleLog = true;

  /// The lowest level threshold to execute the function [exeFinalFunc]
  /// Only logs at or above this level will trigger the final function
  /// Default is warn (executes for warn, error, and fatal levels)
  static DevLevel exeLevel = DevLevel.info;

  /// The lowest level threshold to print logs to console
  /// Logs below this level will be filtered out and not displayed
  /// Default is verbose (prints all logs)
  static DevLevel logLevel = DevLevel.verbose;

  /// Whether to use different background colors when executing final function
  /// When true, uses background colors instead of text colors for [exeFinalFunc] execution
  static bool isExeDiffColor = false;

  /// Prefix string prepended to all log messages
  /// Useful for distinguishing logs from different modules or components
  static String prefixName = '';

  /// Whether to replace newline characters and clean up whitespace for better search visibility in console
  /// Defaults to true in debug mode (kDebugMode), false in release mode
  /// When true, newline characters are replaced with [newlineReplacement] string
  ///
  /// Recommendation:
  /// - Development: true (default in debug mode) for better console searchability
  /// - Production: false (default in release mode) to preserve original formatting
  static bool isReplaceNewline = kDebugMode;

  /// The replacement string for newline characters when [isReplaceNewline] is true
  /// Default is ' • ' (space + bullet + space) - a distinctive separator rarely seen in normal logs
  /// The bullet point provides clear visual separation between content segments
  static String newlineReplacement = ' • ';

  /// Whether to show emoji indicators for log levels
  /// Defaults to true in debug mode (kDebugMode), false in release mode
  /// When true, displays emoji symbols like 🔍, 📬, 🎉, 🚧, ❌, 💣 for each log level
  /// When false, hides emoji indicators and only shows text level names
  ///
  /// Recommendation:
  /// - Development: true (default in debug mode) for better visual feedback
  /// - Production: false (default in release mode) for cleaner logs and better compatibility
  static bool isShowLevelEmojis = kDebugMode;

  /// Whether to enable tag-based filtering
  /// When false (default), all logs are displayed and tag information is shown
  /// When true, only logs with tags matching [tags] set will be output to console
  /// Note: Tag filtering only affects console output, [exeFinalFunc] is always executed regardless
  static bool isFilterByTags = false;

  /// Tag filtering for selective log output
  /// Define the set of tags to display when [isFilterByTags] is enabled
  /// When [isFilterByTags] is false, this set has no filtering effect (logs always display)
  /// When [isFilterByTags] is true and this is not null/empty, only logs matching these tags are shown
  /// - Tags can be automatically extracted from file path directory names
  /// - Tags can be manually specified via the [tag] parameter in log calls
  /// Note: Tag filtering only affects console output, [exeFinalFunc] is always executed regardless
  static Set<String>? tags;

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
  /// @param[msg]: The message string to be logged
  /// @param[level]: The log level (verbose, normal, info, success, warn, error, fatal), defaults to normal
  /// @param[isLog]: If set to true, logs regardless of the static [enable] flag
  /// @param[colorInt]: ANSI color code (0 to 107) for text color customization
  /// @param[fileLocation]: Custom file location string; if null, auto-detects from stack trace
  /// @param[time]: Custom timestamp for the log; if null, uses current time
  /// @param[sequenceNumber]: Sequence number for log ordering
  /// @param[name]: Custom name/tag for the log entry; if null, uses the level name
  /// @param[zone]: Dart Zone where the log originates from
  /// @param[error]: Associated error object to be logged alongside the message
  /// @param[stackTrace]: Stack trace information for debugging
  /// @param[execFinalFunc]: If true, executes the custom final function [exeFinalFunc]
  /// @param[printOnceIfContains]: If provided, only prints once when message contains this keyword
  /// @param[debounceMs]: Debounce time interval in milliseconds, logs within this interval will be discarded
  /// @param[debounceKey]: Custom key for debounce identification (if not provided, uses msg|devLevel|name as fallback)
  /// @param[tag]: Tag for show and filtering; displayed in log output, and when [isFilterByTags] is true, only logs with tags matching [tags] are displayed
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
    String? tag,
  }) {
    int ci = colorInt ??
        (_logColorMap[level] ??
            (defaultColorInt ?? (isMultConsoleLog ? 4 : 0)));
    final String fileInfo =
        fileLocation != null ? '($fileLocation): ' : _getFileLocation();
    final levelMap = {DevLevel.warn: 1000, DevLevel.error: 2000};
    final theName = name ?? level.toString().split('.').last;

    // Extract tag from stack trace if not provided
    final effectiveTag = tag ?? _getTagFromStackTrace();

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
      tag: effectiveTag,
    );
  }

  /// Log supporting on multiple consoles
  /// @param[object]: The object to be logged (will be converted to string)
  /// @param[name]: Custom name/tag for the log entry; if null, uses the level name with dbgPrt/unlPrt prefix
  /// @param[level]: The log level (verbose, normal, info, success, warn, error, fatal), defaults to normal
  /// @param[colorInt]: ANSI color code (0 to 107) for text color customization
  /// @param[isLog]: If set to true, logs regardless of the static [enable] flag
  /// @param[fileLocation]: Custom file location string; if null, auto-detects from stack trace
  /// @param[isDebug]: If true, prints only on debug mode; if null, uses static [isDebugPrint]
  /// @param[execFinalFunc]: If true, executes the custom final function [exeFinalFunc]
  /// @param[error]: Associated error object to be logged alongside the message
  /// @param[stackTrace]: Stack trace information for debugging
  /// @param[printOnceIfContains]: If provided, only prints once when message contains this keyword
  /// @param[debounceMs]: Debounce time interval in milliseconds, logs within this interval will be discarded
  /// @param[debounceKey]: Custom key for debounce identification (if not provided, uses msg|devLevel|name as fallback)
  /// @param[tag]: Tag for show and filtering; displayed in log output, and when [isFilterByTags] is true, only logs with tags matching [tags] are displayed
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
      String? debounceKey,
      String? tag}) {
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

    // Extract tag from stack trace if not provided
    final effectiveTag = tag ?? _getTagFromStackTrace();

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
      tag: effectiveTag,
    );
  }

  /// Execute custom final func with purple text or blue text with multiple consoles
  /// @param[msg]: The message string to be logged
  /// @param[name]: Custom name/tag for the log entry; if null, uses the level name (with prefix for multi-console)
  /// @param[level]: The log level (verbose, normal, info, success, warn, error, fatal), defaults to normal
  /// @param[isLog]: If set to true, logs regardless of the static [enable] flag
  /// @param[isMultConsole]: If true, enables multi-console logging mode with dbgPrt/unlPrt prefix
  /// @param[isDebug]: If true, prints only on debug mode; if null, uses static [isDebugPrint]
  /// @param[colorInt]: ANSI color code (0 to 107) for text color customization
  /// @param[fileInfo]: Custom file location string; if null, auto-detects from stack trace
  /// @param[error]: Associated error object to be logged alongside the message
  /// @param[stackTrace]: Stack trace information for debugging
  /// @param[printOnceIfContains]: If provided, only prints once when message contains this keyword
  /// @param[debounceMs]: Debounce time interval in milliseconds, logs within this interval will be discarded
  /// @param[debounceKey]: Custom key for debounce identification (if not provided, uses msg|devLevel|name as fallback)
  /// @param[tag]: Tag for show and filtering; displayed in log output, and when [isFilterByTags] is true, only logs with tags matching [tags] are displayed
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
      String? debounceKey,
      String? tag}) {
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

    // Extract tag from stack trace if not provided
    final effectiveTag = tag ?? _getTagFromStackTrace();

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
      tag: effectiveTag,
    );
  }

  /// Execute verbose level log with custom final function
  /// @param[msg]: The message string to be logged
  /// @param[isLog]: If set to true, logs regardless of the static [enable] flag
  /// @param[isMultConsole]: If true, enables multi-console logging mode
  /// @param[isDebug]: If true, prints only on debug mode; if null, uses static [isDebugPrint]
  /// @param[colorInt]: ANSI color code (0 to 107) for text color customization
  /// @param[printOnceIfContains]: If provided, only prints once when message contains this keyword
  /// @param[debounceMs]: Debounce time interval in milliseconds, logs within this interval will be discarded
  /// @param[debounceKey]: Custom key for debounce identification (if not provided, uses msg|devLevel|name as fallback)
  /// @param[tag]: Tag for show and filtering; displayed in log output, and when [isFilterByTags] is true, only logs with tags matching [tags] are displayed
  static void exeVerbose(
    String msg, {
    bool? isLog,
    bool? isMultConsole,
    bool? isDebug,
    int? colorInt,
    String? printOnceIfContains,
    int debounceMs = 0,
    String? debounceKey,
    String? tag,
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
        debounceKey: debounceKey,
        tag: tag);
  }

  /// Execute info level log with custom final function
  /// @param[msg]: The message string to be logged
  /// @param[isLog]: If set to true, logs regardless of the static [enable] flag
  /// @param[isMultConsole]: If true, enables multi-console logging mode
  /// @param[isDebug]: If true, prints only on debug mode; if null, uses static [isDebugPrint]
  /// @param[colorInt]: ANSI color code (0 to 107) for text color customization
  /// @param[printOnceIfContains]: If provided, only prints once when message contains this keyword
  /// @param[debounceMs]: Debounce time interval in milliseconds, logs within this interval will be discarded
  /// @param[debounceKey]: Custom key for debounce identification (if not provided, uses msg|devLevel|name as fallback)
  /// @param[tag]: Tag for show and filtering; displayed in log output, and when [isFilterByTags] is true, only logs with tags matching [tags] are displayed
  static void exeInfo(
    String msg, {
    bool? isLog,
    bool? isMultConsole,
    bool? isDebug,
    int? colorInt,
    String? printOnceIfContains,
    int debounceMs = 0,
    String? debounceKey,
    String? tag,
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
        debounceKey: debounceKey,
        tag: tag);
  }

  /// Execute success level log with custom final function
  /// @param[msg]: The message string to be logged
  /// @param[isLog]: If set to true, logs regardless of the static [enable] flag
  /// @param[isMultConsole]: If true, enables multi-console logging mode
  /// @param[isDebug]: If true, prints only on debug mode; if null, uses static [isDebugPrint]
  /// @param[colorInt]: ANSI color code (0 to 107) for text color customization
  /// @param[printOnceIfContains]: If provided, only prints once when message contains this keyword
  /// @param[debounceMs]: Debounce time interval in milliseconds, logs within this interval will be discarded
  /// @param[debounceKey]: Custom key for debounce identification (if not provided, uses msg|devLevel|name as fallback)
  /// @param[tag]: Tag for show and filtering; displayed in log output, and when [isFilterByTags] is true, only logs with tags matching [tags] are displayed
  static void exeSuccess(
    String msg, {
    bool? isLog,
    bool? isMultConsole,
    bool? isDebug,
    int? colorInt,
    String? printOnceIfContains,
    int debounceMs = 0,
    String? debounceKey,
    String? tag,
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
        debounceKey: debounceKey,
        tag: tag);
  }

  /// Execute warn level log with custom final function
  /// @param[msg]: The message string to be logged
  /// @param[isLog]: If set to true, logs regardless of the static [enable] flag
  /// @param[isMultConsole]: If true, enables multi-console logging mode
  /// @param[isDebug]: If true, prints only on debug mode; if null, uses static [isDebugPrint]
  /// @param[colorInt]: ANSI color code (0 to 107) for text color customization
  /// @param[printOnceIfContains]: If provided, only prints once when message contains this keyword
  /// @param[debounceMs]: Debounce time interval in milliseconds, logs within this interval will be discarded
  /// @param[debounceKey]: Custom key for debounce identification (if not provided, uses msg|devLevel|name as fallback)
  /// @param[tag]: Tag for show and filtering; displayed in log output, and when [isFilterByTags] is true, only logs with tags matching [tags] are displayed
  static void exeWarn(
    String msg, {
    bool? isLog,
    bool? isMultConsole,
    bool? isDebug,
    int? colorInt,
    String? printOnceIfContains,
    int debounceMs = 0,
    String? debounceKey,
    String? tag,
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
        debounceKey: debounceKey,
        tag: tag);
  }

  /// @deprecated Use [exeWarn] instead. This will be removed in future versions.
  /// Execute warning level log with custom final function (deprecated)
  /// @param[msg]: The message string to be logged
  /// @param[isLog]: If set to true, logs regardless of the static [enable] flag
  /// @param[isMultConsole]: If true, enables multi-console logging mode
  /// @param[isDebug]: If true, prints only on debug mode; if null, uses static [isDebugPrint]
  /// @param[colorInt]: ANSI color code (0 to 107) for text color customization
  /// @param[printOnceIfContains]: If provided, only prints once when message contains this keyword
  /// @param[debounceMs]: Debounce time interval in milliseconds, logs within this interval will be discarded
  /// @param[debounceKey]: Custom key for debounce identification (if not provided, uses msg|devLevel|name as fallback)
  /// @param[tag]: Tag for show and filtering; displayed in log output, and when [isFilterByTags] is true, only logs with tags matching [tags] are displayed
  @Deprecated('Use exeWarn instead')
  static void exeWarning(
    String msg, {
    bool? isLog,
    bool? isMultConsole,
    bool? isDebug,
    int? colorInt,
    String? printOnceIfContains,
    int debounceMs = 0,
    String? debounceKey,
    String? tag,
  }) {
    exeWarn(msg,
        isLog: isLog,
        isMultConsole: isMultConsole,
        isDebug: isDebug,
        colorInt: colorInt,
        printOnceIfContains: printOnceIfContains,
        debounceMs: debounceMs,
        debounceKey: debounceKey,
        tag: tag);
  }

  /// Execute error level log with custom final function
  /// @param[msg]: The message string to be logged
  /// @param[isLog]: If set to true, logs regardless of the static [enable] flag
  /// @param[isMultConsole]: If true, enables multi-console logging mode
  /// @param[isDebug]: If true, prints only on debug mode; if null, uses static [isDebugPrint]
  /// @param[colorInt]: ANSI color code (0 to 107) for text color customization
  /// @param[error]: Associated error object to be logged alongside the message
  /// @param[stackTrace]: Stack trace information for debugging
  /// @param[printOnceIfContains]: If provided, only prints once when message contains this keyword
  /// @param[debounceMs]: Debounce time interval in milliseconds, logs within this interval will be discarded
  /// @param[debounceKey]: Custom key for debounce identification (if not provided, uses msg|devLevel|name as fallback)
  /// @param[tag]: Tag for show and filtering; displayed in log output, and when [isFilterByTags] is true, only logs with tags matching [tags] are displayed
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
    String? tag,
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
        debounceKey: debounceKey,
        tag: tag);
  }

  /// Execute fatal level log with custom final function
  /// @param[msg]: The message string to be logged
  /// @param[isLog]: If set to true, logs regardless of the static [enable] flag
  /// @param[isMultConsole]: If true, enables multi-console logging mode
  /// @param[isDebug]: If true, prints only on debug mode; if null, uses static [isDebugPrint]
  /// @param[colorInt]: ANSI color code (0 to 107) for text color customization
  /// @param[printOnceIfContains]: If provided, only prints once when message contains this keyword
  /// @param[debounceMs]: Debounce time interval in milliseconds, logs within this interval will be discarded
  /// @param[debounceKey]: Custom key for debounce identification (if not provided, uses msg|devLevel|name as fallback)
  /// @param[tag]: Tag for show and filtering; displayed in log output, and when [isFilterByTags] is true, only logs with tags matching [tags] are displayed
  static void exeFatal(
    String msg, {
    bool? isLog,
    bool? isMultConsole,
    bool? isDebug,
    int? colorInt,
    String? printOnceIfContains,
    int debounceMs = 0,
    String? debounceKey,
    String? tag,
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
        debounceKey: debounceKey,
        tag: tag);
  }

  /// Verbose - Dark gray text for detailed debug information
  /// Use for verbose debugging details
  /// @param[msg]: The message string to be logged
  /// @param[isLog]: If set to true, logs regardless of the static [enable] flag
  /// @param[execFinalFunc]: If true, executes the custom final function [exeFinalFunc]
  /// @param[printOnceIfContains]: If provided, only prints once when message contains this keyword
  /// @param[debounceMs]: Debounce time interval in milliseconds, logs within this interval will be discarded
  /// @param[debounceKey]: Custom key for debounce identification (if not provided, uses msg|devLevel|name as fallback)
  /// @param[tag]: Tag for show and filtering; displayed in log output, and when [isFilterByTags] is true, only logs with tags matching [tags] are displayed
  static void logVerbose(String msg,
      {bool? isLog,
      bool? execFinalFunc,
      String? printOnceIfContains,
      int debounceMs = 0,
      String? debounceKey,
      String? tag}) {
    final String fileInfo = _getFileLocation();
    final effectiveTag = tag ?? _getTagFromStackTrace();
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
      tag: effectiveTag,
    );
  }

  /// Fatal/Critical error - text (orange/purple)
  /// Use for fatal errors that require immediate attention
  /// @param[msg]: The message string to be logged
  /// @param[isLog]: If set to true, logs regardless of the static [enable] flag
  /// @param[execFinalFunc]: If true, executes the custom final function [exeFinalFunc]
  /// @param[printOnceIfContains]: If provided, only prints once when message contains this keyword
  /// @param[debounceMs]: Debounce time interval in milliseconds, logs within this interval will be discarded
  /// @param[debounceKey]: Custom key for debounce identification (if not provided, uses msg|devLevel|name as fallback)
  /// @param[tag]: Tag for show and filtering; displayed in log output, and when [isFilterByTags] is true, only logs with tags matching [tags] are displayed
  static void logFatal(String msg,
      {bool? isLog,
      bool? execFinalFunc,
      String? printOnceIfContains,
      int debounceMs = 0,
      String? debounceKey,
      String? tag}) {
    final String fileInfo = _getFileLocation();
    final effectiveTag = tag ?? _getTagFromStackTrace();
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
      tag: effectiveTag,
    );
  }

  /// Info - Blue text for informational messages
  /// @param[msg]: The message string to be logged
  /// @param[isLog]: If set to true, logs regardless of the static [enable] flag
  /// @param[execFinalFunc]: If true, executes the custom final function [exeFinalFunc]
  /// @param[printOnceIfContains]: If provided, only prints once when message contains this keyword
  /// @param[debounceMs]: Debounce time interval in milliseconds, logs within this interval will be discarded
  /// @param[debounceKey]: Custom key for debounce identification (if not provided, uses msg|devLevel|name as fallback)
  /// @param[tag]: Tag for show and filtering; displayed in log output, and when [isFilterByTags] is true, only logs with tags matching [tags] are displayed
  static void logInfo(String msg,
      {bool? isLog,
      bool? execFinalFunc,
      String? printOnceIfContains,
      int debounceMs = 0,
      String? debounceKey,
      String? tag}) {
    final String fileInfo = _getFileLocation();
    final effectiveTag = tag ?? _getTagFromStackTrace();
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
      tag: effectiveTag,
    );
  }

  /// Success - Green text for success/completion messages
  /// @param[msg]: The message string to be logged
  /// @param[isLog]: If set to true, logs regardless of the static [enable] flag
  /// @param[execFinalFunc]: If true, executes the custom final function [exeFinalFunc]
  /// @param[printOnceIfContains]: If provided, only prints once when message contains this keyword
  /// @param[debounceMs]: Debounce time interval in milliseconds, logs within this interval will be discarded
  /// @param[debounceKey]: Custom key for debounce identification (if not provided, uses msg|devLevel|name as fallback)
  /// @param[tag]: Tag for show and filtering; displayed in log output, and when [isFilterByTags] is true, only logs with tags matching [tags] are displayed
  static void logSuccess(String msg,
      {bool? isLog,
      bool? execFinalFunc,
      String? printOnceIfContains,
      int debounceMs = 0,
      String? debounceKey,
      String? tag}) {
    final String fileInfo = _getFileLocation();
    final effectiveTag = tag ?? _getTagFromStackTrace();
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
      tag: effectiveTag,
    );
  }

  /// Warn - Yellow text for warning messages
  /// @param[msg]: The message string to be logged
  /// @param[isLog]: If set to true, logs regardless of the static [enable] flag
  /// @param[execFinalFunc]: If true, executes the custom final function [exeFinalFunc]
  /// @param[printOnceIfContains]: If provided, only prints once when message contains this keyword
  /// @param[debounceMs]: Debounce time interval in milliseconds, logs within this interval will be discarded
  /// @param[debounceKey]: Custom key for debounce identification (if not provided, uses msg|devLevel|name as fallback)
  /// @param[tag]: Tag for show and filtering; displayed in log output, and when [isFilterByTags] is true, only logs with tags matching [tags] are displayed
  static void logWarn(String msg,
      {bool? isLog,
      bool? execFinalFunc,
      String? printOnceIfContains,
      int debounceMs = 0,
      String? debounceKey,
      String? tag}) {
    final String fileInfo = _getFileLocation();
    final effectiveTag = tag ?? _getTagFromStackTrace();
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
      tag: effectiveTag,
    );
  }

  /// @deprecated Use [logWarn] instead. This will be removed in future versions.
  /// Warning - Yellow text for warning messages (deprecated, use logWarn)
  /// @param[msg]: The message string to be logged
  /// @param[isLog]: If set to true, logs regardless of the static [enable] flag
  /// @param[execFinalFunc]: If true, executes the custom final function [exeFinalFunc]
  /// @param[printOnceIfContains]: If provided, only prints once when message contains this keyword
  /// @param[debounceMs]: Debounce time interval in milliseconds, logs within this interval will be discarded
  /// @param[debounceKey]: Custom key for debounce identification (if not provided, uses msg|devLevel|name as fallback)
  /// @param[tag]: Tag for show and filtering; displayed in log output, and when [isFilterByTags] is true, only logs with tags matching [tags] are displayed
  @Deprecated('Use logWarn instead')
  static void logWarning(String msg,
      {bool? isLog,
      bool? execFinalFunc,
      String? printOnceIfContains,
      int debounceMs = 0,
      String? debounceKey,
      String? tag}) {
    logWarn(msg,
        isLog: isLog,
        execFinalFunc: execFinalFunc,
        printOnceIfContains: printOnceIfContains,
        debounceMs: debounceMs,
        debounceKey: debounceKey,
        tag: tag);
  }

  /// Error - Red text for error messages
  /// @param[msg]: The message string to be logged
  /// @param[isLog]: If set to true, logs regardless of the static [enable] flag
  /// @param[execFinalFunc]: If true, executes the custom final function [exeFinalFunc]
  /// @param[error]: Associated error object to be logged alongside the message
  /// @param[stackTrace]: Stack trace information for debugging
  /// @param[printOnceIfContains]: If provided, only prints once when message contains this keyword
  /// @param[debounceMs]: Debounce time interval in milliseconds, logs within this interval will be discarded
  /// @param[debounceKey]: Custom key for debounce identification (if not provided, uses msg|devLevel|name as fallback)
  /// @param[tag]: Tag for show and filtering; displayed in log output, and when [isFilterByTags] is true, only logs with tags matching [tags] are displayed
  static void logError(String msg,
      {bool? isLog,
      bool? execFinalFunc,
      Object? error,
      StackTrace? stackTrace,
      String? printOnceIfContains,
      int debounceMs = 0,
      String? debounceKey,
      String? tag}) {
    final String fileInfo = _getFileLocation();
    final effectiveTag = tag ?? _getTagFromStackTrace();
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
      tag: effectiveTag,
    );
  }
}
