# Dev Colorized Log

[![pub package](https://img.shields.io/pub/v/dev_colorized_log.svg)](https://github.com/janlionly/flutter_dev_colorized_log)<a href="https://github.com/janlionly/flutter_dev_colorized_log"><img src="https://img.shields.io/github/stars/janlionly/flutter_dev_colorized_log.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>

A powerful and flexible Flutter/Dart logging utility with colorized console output, advanced filtering, performance optimizations, and developer-friendly features for efficient debugging and monitoring.

## Key Features

- **🎨 Colorized Output**: 7 log levels with distinct ANSI colors (verbose, normal, info, success, warn, error, fatal)
- **🔍 Smart Filtering**: Dual-level filtering with `logLevel` (console output) and `exeLevel` (custom callbacks)
- **⚡ Performance Optimized**: Lightweight mode and optimized stack trace parsing (40-60% faster) for production use
- **🚫 Debounce & Deduplication**: Prevent log spam with `debounceMs` and one-time logging with `printOnceIfContains`
- **📍 File Location Tracking**: Automatic file name and line number detection for quick debugging
- **🔧 Custom Callbacks**: Execute custom functions (`exeFinalFunc`) for remote logging, analytics, or file writing
- **📱 Multi-Platform Support**: Enhanced formatting for Xcode, VS Code, Terminal, and other consoles
- **⏰ Timestamps**: Optional date/time display in logs
- **📝 Multi-line Handling**: Automatic newline replacement for better console searchability
- **🎯 Flexible Configuration**: Global settings with per-log overrides for maximum control

## Usage

See examples in the `/example` folder. For more details, please run the example project.

```dart
/* Global settings:*/
Dev.enable = true; // Whether to log messages
Dev.isLogFileLocation = true; // Whether to log the file location info
Dev.defaultColorInt = 0; // Default text color, int value from 0 to 107
Dev.isDebugPrint = true; // Whether Dev.print logs only in debug mode

/// V 2.1.0 Log level filtering - control which logs are printed to the console
/// Set the minimum log level threshold - logs below this level will be filtered from the console
/// Note: logLevel only filters console output, exeFinalFunc callbacks still execute for all levels
Dev.logLevel = DevLevel.verbose; // Default: show all logs in the console
Dev.logLevel = DevLevel.info; // Console: only show info, success, warning, error, and fatal
Dev.logLevel = DevLevel.warn; // Console: only show warning, error, and fatal
Dev.logLevel = DevLevel.error; // Console: only show error and fatal

// Example: Production environment - only show warnings and above in the console
Dev.logLevel = DevLevel.warn;
Dev.exeLevel = DevLevel.error; // Only error+ will trigger exeFinalFunc

Dev.logVerbose('Debug details'); // Console: filtered, Callback: filtered
Dev.log('Normal log'); // Console: filtered, Callback: filtered
Dev.logInfo('API response received'); // Console: filtered, Callback: filtered
Dev.logSuccess('Task completed'); // Console: filtered, Callback: filtered
Dev.logWarn('Deprecated API used'); // Console: ✓ shown, Callback: filtered (below exeLevel)
Dev.logError('Network error'); // Console: ✓ shown, Callback: ✓ executed
Dev.logFatal('Critical failure!'); // Console: ✓ shown, Callback: ✓ executed

/// V 2.0.9 debounceMs + debounceKey for throttling rapid log calls
/// Use the debounceMs parameter to prevent log spam from repeated calls
/// Use debounceKey when the log message contains dynamic content (timestamps, counters, etc.)
Dev.logWarning('Button clicked', debounceMs: 2000); // Only logs once every 2 seconds
Dev.logInfo('API call at ${DateTime.now()}', debounceMs: 1000, debounceKey: 'api_call'); // Logs with dynamic content
Dev.clearDebounceTimestamps(); // Clear all debounce states if needed

/// V 2.0.8 Performance optimization options
Dev.isLightweightMode = false; // Skip stack trace capture for maximum performance (recommended for production)
Dev.useOptimizedStackTrace = true; // Use stack_trace package for 40-60% better performance (default: true)

/// V 2.0.7 printOnceIfContains for one-time logging when the message contains a keyword
/// Use the printOnceIfContains parameter to ensure only the first log containing the keyword is printed
Dev.log('Error: USER-001 login failed', printOnceIfContains: 'USER-001');
Dev.log('Retry: USER-001 timeout again', printOnceIfContains: 'USER-001'); // Skipped! (message contains 'USER-001' which was already logged)
Dev.clearCachedKeys(); // Clear all cached keywords if needed

/// V 2.0.4 newline replacement for better search visibility in the console
Dev.isReplaceNewline = true; // Whether to replace newline characters (default: false)
Dev.newlineReplacement = ' | '; // Replacement string for newlines (default: ' | ')

/// V 2.0.3 prefix name for all logs
Dev.prefixName = 'MyApp'; // Custom prefix name to prepend to all log messages

/// V 2.0.2 execFinalFunc with different color
Dev.isExeDiffColor = false; // Whether to use different colors for exeFinalFunc logs

/// V 2.0.0 Set the minimum level threshold to execute the custom final function
Dev.exeLevel = DevLevel.logWar;
Dev.customFinalFunc = (msg, level) {
  // Example: write message to file or send to analytics
  writeToFile(msg, level);
};

/// V 1.2.8 Colorize multi-line logs
Dev.log('===================== Colorize multi-line log =====================');
const multiLines = '''
      🔴 [ERROR] UniqueID: 1
      🕒 Timestamp: 2
      📛 ErrorType: 3
      💥 ErrorMessage: 4
      📚 StackTrace: 5
    ''';
const multiLines2 = 'Error1\nError2\nError3';
Dev.logError(multiLines);
Dev.logError(multiLines2);
/// V 1.2.8 Special error format logging with error objects
Dev.print(e, error: e, level: DevLevel.logErr);
Dev.logError('$e', error: e);
Dev.exeError('$e', error: e, colorInt: 91);

/// V1.2.6 Enable logging on multiple platform consoles (Xcode, VS Code, Terminal, etc.)
Dev.isMultConsoleLog = true;

/// V1.2.2 Log display settings
Dev.isLogShowDateTime = true; // Whether to show date and time in logs
Dev.isExeWithShowLog = true; // Whether to show logs when executing exeFinalFunc
Dev.isExeWithDateTime = false; // Whether to include date and time in exeFinalFunc callbacks

/// V1.2.1 Execute methods that trigger custom callbacks
Dev.exe("Exec Normal");
Dev.exeInfo("Exec Info");
Dev.exeSuccess("Exec Success");
Dev.exeWarning("Exec Warning");
Dev.exeError("Exec Error");
Dev.exeBlink("Exec Blink");
Dev.exe("Exec Normal without log", isLog: false);

Dev.log('1.log success level', level: DevLevel.logSuc);
Dev.logSuccess('2.log success level');
Dev.log('1.log success level and exec', level: DevLevel.logSuc, execFinalFunc: true);
Dev.exe('2.log success level and exec', level: DevLevel.logSuc);
Dev.exeSuccess('3.log success level and exec');
// END

/// V1.2.0 Execute custom function with colorized output
Dev.exe('!!! Exec Normal');
Dev.exe('!!! Exec Colorized text Info Without log', level: DevLevel.logInf, isMultConsole: true, isLog: false, colorInt: 101);
Dev.print('Colorized text print with the given level', level: DevLevel.logWar);
// END

// All log level functions support the execFinalFunc parameter:
Dev.log('Colorized text log to your custom log processing', execFinalFunc: true);

/// V1.1.6 Custom function to support your own log processing
// Deprecated: Use exeFinalFunc instead (customFinalFunc will be removed in future versions)
// Dev.customFinalFunc = (msg, level) {
//   writeToFile(msg, level);
// };

## Migration Guide

### DevLevel Enum Renaming (v2.1.0+)

In version 2.1.0, the `DevLevel` enum values have been renamed for better readability:

**Old names → New names:**
- `DevLevel.logVer` → `DevLevel.verbose`
- `DevLevel.logNor` → `DevLevel.normal`
- `DevLevel.logInf` → `DevLevel.info`
- `DevLevel.logSuc` → `DevLevel.success`
- `DevLevel.logWar` → `DevLevel.warn`
- `DevLevel.logErr` → `DevLevel.error`
- `DevLevel.logBlk` → `DevLevel.fatal`

**Migration example:**

```dart
// Old way (v2.0.x and earlier):
Dev.log('Message', level: DevLevel.logWar); // → DevLevel.warn
Dev.exeLevel = DevLevel.logErr;
Dev.print('Print', level: DevLevel.logInf);

// New way (v2.1.0+):
Dev.log('Message', level: DevLevel.warn);
Dev.exeLevel = DevLevel.error;
Dev.print('Print', level: DevLevel.info);

// Quick find & replace in your codebase:
// DevLevel.logVer → DevLevel.verbose
// DevLevel.logNor → DevLevel.normal
// DevLevel.logInf → DevLevel.info
// DevLevel.logSuc → DevLevel.success
// DevLevel.logWar → DevLevel.warn
// DevLevel.logErr → DevLevel.error
// DevLevel.logBlk → DevLevel.fatal
```

**Note:** The log method names remain unchanged (`logInfo`, `logWarning`, `logError`, etc.).

### Method Renaming: logBlink/exeBlink → logFatal/exeFatal (v2.1.0+)

For consistency with the new enum naming, the "blink" methods have been renamed to "fatal":

**Old methods → New methods:**
- `Dev.logBlink()` → `Dev.logFatal()` ✅
- `Dev.exeBlink()` → `Dev.exeFatal()` ✅

**Migration example:**

```dart
// Old way (v2.0.x and earlier):
Dev.logBlink('System crash!');
Dev.exeBlink('Critical error!');

// New way (v2.1.0+):
Dev.logFatal('System crash!');
Dev.exeFatal('Critical error!');
```

**Note:** The old methods (`logBlink`, `exeBlink`) have been **removed**. Please update your code to use the new method names `logFatal` and `exeFatal`.

### New Shorter Method Names: logWarn/exeWarn (v2.1.0+)

For consistency with the shortened enum value `DevLevel.warn`, new shorter method names are now recommended:

**Old methods → New recommended methods:**
- `Dev.logWarning()` → `Dev.logWarn()` ✅
- `Dev.exeWarning()` → `Dev.exeWarn()` ✅

**Migration example:**

```dart
// Old way (still works, but deprecated):
Dev.logWarning('Slow query detected');
Dev.exeWarning('Memory usage high');

// New recommended way (v2.1.0+):
Dev.logWarn('Slow query detected');
Dev.exeWarn('Memory usage high');
```

**Note:** The old methods (`logWarning`, `exeWarning`) are deprecated but still functional for backward compatibility. We recommend migrating to the shorter names for consistency.

### From customFinalFunc to exeFinalFunc (v2.0.6+)

The `customFinalFunc` has been renamed to `exeFinalFunc` for better naming consistency. The old name is deprecated but still works for backward compatibility.

**Old way (deprecated):**
```dart
Dev.customFinalFunc = (msg, level) {
  writeToFile(msg, level);
};
```

**New way (recommended):**
```dart
Dev.exeFinalFunc = (msg, level) {
  writeToFile(msg, level);
};
```

**Priority:** If both `exeFinalFunc` and `customFinalFunc` are set, `exeFinalFunc` takes priority.

**Infinite Recursion Prevention:** The library automatically prevents infinite recursion when `exeFinalFunc` or `customFinalFunc` internally calls Dev logging methods (such as `Dev.exeError`, `Dev.exe`, etc.).

```dart
// Safe: This won't cause infinite recursion
Dev.exeFinalFunc = (msg, level) {
  writeToFile(msg, level);
  Dev.exeError('Also log this error'); // Won't trigger exeFinalFunc again
};
```

```dart
/* Log usage: */
Dev.log('Colorized text log'); // Default yellow text
Dev.logInfo('Colorized text Info'); // Blue text
Dev.logSuccess('Colorized text Success', execFinalFunc: true); // Green text
Dev.logWarning('Colorized text Warning'); // Yellow text
Dev.logError('Colorized text Error'); // Red text
Dev.logBlink('Colorized text blink', isSlow: true, isLog: true); // Blinking orange text

// Support for logging on multiple platform consoles like Xcode and VS Code
Dev.print('Dev text print', isDebug: true); // Logs only in debug mode by default

// Custom options:
Dev.log('Colorized text log with custom options', fileLocation: 'main.dart:90xx', colorInt: 96);
```

```dart
// Example: Multi-line log for better search visibility
const errorDetails = '''Error occurred:
- File: user.dart:123
- Function: validateEmail()
- Reason: Invalid format''';

// With replacement enabled (better for searching in console):
Dev.logError(errorDetails);
// Output: Error occurred: | - File: user.dart:123 | - Function: validateEmail() | - Reason: Invalid format

// Example with messy whitespace:
const messyLog = '''  Error:
	Multiple    spaces   and	tabs
   End with spaces  ''';

// With replacement enabled - automatically cleans up extra whitespace:
Dev.logError(messyLog);
// Output: Error: | Multiple spaces and tabs | End with spaces

// Without replacement (preserves original formatting):
Dev.isReplaceNewline = false;
Dev.logError(errorDetails);
// Output: Error occurred:
//         - File: user.dart:123
//         - Function: validateEmail()
//         - Reason: Invalid format
```

```dart
// Example: printOnceIfContains for one-time logging (v2.0.7+)
// Useful for preventing duplicate error logs in loops or repeated function calls
for (var i = 0; i < 100; i++) {
  // Only logs the FIRST time a message containing 'API-ERROR-500' is encountered
  Dev.logWarning('Request failed: API-ERROR-500 timeout', printOnceIfContains: 'API-ERROR-500');
  // Subsequent logs containing 'API-ERROR-500' are automatically skipped
}

// Different keywords are tracked independently
Dev.log('User login failed: ERROR-001', printOnceIfContains: 'ERROR-001');  // ✓ Logged
Dev.log('Database error: ERROR-002', printOnceIfContains: 'ERROR-002'); // ✓ Logged
Dev.log('Retry login: ERROR-001 again', printOnceIfContains: 'ERROR-001'); // ✗ Skipped (contains 'ERROR-001')
Dev.log('DB connection lost: ERROR-002', printOnceIfContains: 'ERROR-002'); // ✗ Skipped (contains 'ERROR-002')

// If message doesn't contain the keyword, it always logs
Dev.log('Normal log without error code', printOnceIfContains: 'ERROR-999'); // ✓ Logged (doesn't contain 'ERROR-999')

// Clear cache to allow logs to appear again
Dev.clearCachedKeys();
Dev.log('After clear: ERROR-001 can log again', printOnceIfContains: 'ERROR-001'); // ✓ Logged (cache was cleared)

// Practical use case: Log unique user actions once per session
Dev.logInfo('User user-123 logged in', printOnceIfContains: 'user-123');
Dev.logInfo('User user-123 clicked button', printOnceIfContains: 'user-123'); // ✗ Skipped
Dev.logInfo('User user-456 logged in', printOnceIfContains: 'user-456'); // ✓ Logged (different user)

// Works with all log methods
Dev.logInfo('Info: token-abc expired', printOnceIfContains: 'token-abc');
Dev.logError('Error: connection-lost', printOnceIfContains: 'connection-lost');
Dev.exe('Execute: task-001 started', printOnceIfContains: 'task-001');
Dev.print('Print: session-xyz created', printOnceIfContains: 'session-xyz');
```

```dart
// Debounce Examples (v2.0.9+)
// Prevent log spam from rapid repeated calls

// Example 1: Debounce button clicks with static message
void onButtonPressed() {
  // Only logs once every 2 seconds, even if clicked 100 times
  Dev.logInfo('Button clicked!', debounceMs: 2000);
}

// Example 1b: Debounce with dynamic message content
void onButtonPressedWithTimestamp() {
  // Use debounceKey when the message contains dynamic content (timestamp, counter, etc.)
  Dev.logInfo('Button clicked at ${DateTime.now()}',
      debounceMs: 2000,
      debounceKey: 'button_click');
  // Without debounceKey, each click would have a unique message and wouldn't be debounced
}

// Example 2: Debounce scroll events with dynamic values
void onScroll(double offset) {
  // Use debounceKey because the offset value changes every time
  Dev.log('Scroll offset: $offset px',
      debounceMs: 500,
      debounceKey: 'scroll_event');
  // All scroll events share the same debounceKey, so it only logs once per 500ms
}

// Example 3: Debounce API requests with attempt counter
int attemptCount = 0;
void fetchData() {
  attemptCount++;
  // Use debounceKey because the message contains dynamic attemptCount
  Dev.exeWarning('API request attempt $attemptCount',
      debounceMs: 1000,
      debounceKey: 'api_fetch');
  // Only logs once per second, even though attemptCount changes
}

// Example 4: Different messages have independent debounce timers
Dev.logWarning('Message A', debounceMs: 1000); // ✓ Logged immediately
Dev.logWarning('Message B', debounceMs: 1000); // ✓ Logged (different message)
Dev.logWarning('Message A', debounceMs: 1000); // ✗ Skipped (within 1s of first 'Message A')

// Example 5: Combine with exeFinalFunc to prevent overwhelming log files
Dev.exeFinalFunc = (msg, level) {
  writeToFile(msg, level);
};
// Prevents overwhelming the log file with repeated errors
Dev.exeError('Network timeout', debounceMs: 3000); // Only written once every 3 seconds

// Example 6: Clear debounce state when needed
// ❌ Wrong - message changes each iteration, so all 10 logs will print
// for (int i = 0; i < 10; i++) {
//   Dev.logInfo('Loop iteration $i', debounceMs: 500);
// }

// ✓ Correct - use debounceKey for dynamic message content
for (int i = 0; i < 10; i++) {
  Dev.logInfo('Loop iteration $i',
      debounceMs: 500,
      debounceKey: 'loop_log'); // Only the first one logs
}
Dev.clearDebounceTimestamps(); // Reset all debounce states
Dev.logInfo('Loop iteration 0',
    debounceMs: 500,
    debounceKey: 'loop_log'); // ✓ Now logs again

// Important: When to use debounceKey
// ✓ Use debounceKey when the message contains dynamic content:
//   - Timestamps: 'Event at ${DateTime.now()}'
//   - Counters: 'Attempt $count'
//   - User input: 'Search query: $userInput'
//   - Positions: 'Scroll offset: $offset'
// ✗ No need for debounceKey when the message is static:
//   - 'Button clicked' - message is always the same
//   - 'API failed' - no dynamic content

// Practical use cases for debouncing:
// - Button click handlers (prevent double-click spam)
// - Scroll event listeners (reduce noise during continuous scrolling)
// - API retry logic (avoid flooding logs with repeated failures)
// - Form validation (throttle real-time validation logs)
// - Animation frame callbacks (limit logs during animations)
// - Mouse move/hover events with coordinates (use debounceKey: 'mouse_move')
// - Network status changes with timestamps (use debounceKey: 'network_status')

// Works with all log methods
Dev.log('Normal log', debounceMs: 1000);
Dev.logInfo('Info log', debounceMs: 1500);
Dev.logSuccess('Success log', debounceMs: 2000);
Dev.logWarning('Warning log', debounceMs: 2500);
Dev.logError('Error log', debounceMs: 3000);
Dev.exe('Execute log', debounceMs: 1000);
Dev.print('Print log', debounceMs: 1000);
```

```dart
// Performance Optimization Examples (v2.0.8+)

// Mode 1: Default optimized mode (recommended for development)
Dev.useOptimizedStackTrace = true; // Uses the stack_trace package (40-60% faster)
Dev.isLightweightMode = false;
Dev.logError('Development error with file location'); // Shows: (main.dart:123): Development error...

// Mode 2: Basic optimized mode (no external dependency)
Dev.useOptimizedStackTrace = false; // Uses basic string operations (10-20% faster)
Dev.isLightweightMode = false;
Dev.logWarning('Warning with basic stack trace'); // Shows: (main.dart:456): Warning...

// Mode 3: Maximum performance mode (recommended for production)
Dev.isLightweightMode = true; // Skips stack trace capture completely
Dev.logInfo('Production log'); // No file location shown, maximum performance

// Recommendations:
// - Development: useOptimizedStackTrace = true, isLightweightMode = false
// - Production: isLightweightMode = true (or disable Dev.enable entirely)
```

## Author

Visit my GitHub: [janlionly](https://github.com/janlionly)<br>
Contact me by email: janlionly@gmail.com

## Contribute
I would love for you to contribute to **DevColorizedLog**!

## License
**DevColorizedLog** is available under the MIT license. See the [LICENSE](https://github.com/janlionly/flutter_dev_colorized_log/blob/master/LICENSE) file for more information.