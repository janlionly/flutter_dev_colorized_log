# Dev Colorized Log

[![pub package](https://img.shields.io/pub/v/dev_colorized_log.svg)](https://github.com/janlionly/flutter_dev_colorized_log)<a href="https://github.com/janlionly/flutter_dev_colorized_log"><img src="https://img.shields.io/github/stars/janlionly/flutter_dev_colorized_log.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>

A Flutter package for logging colorized text in developer mode.

## Usage

See examples to `/example` folder, more please run example project.

```dart
/* Global settings:*/
Dev.enable = true; // whether log msg
Dev.isLogFileLocation = true; // whether log the location file info
Dev.defaultColorInt = 0; // default color text, int value from 0 to 107
Dev.isDebugPrint = true; // Dev.print whether only log on debug mode

/// V 2.0.8 Performance optimization options
Dev.isLightweightMode = false; // Skip stack trace capture for maximum performance (recommended for production)
Dev.useOptimizedStackTrace = true; // Use stack_trace package for 40-60% better performance (default: true)

/// V 2.0.7 printOnceIfContains for one-time logging when message contains keyword
/// Use printOnceIfContains parameter to ensure only first log containing the keyword is printed
Dev.log('Error: USER-001 login failed', printOnceIfContains: 'USER-001');
Dev.log('Retry: USER-001 timeout again', printOnceIfContains: 'USER-001'); // Skipped! (message contains 'USER-001' which was already logged)
Dev.clearCachedKeys(); // Clear all cached keywords if needed

/// V 2.0.4 newline replacement for better search visibility in console
Dev.isReplaceNewline = true; // whether replace newline characters (default false)
Dev.newlineReplacement = ' | '; // replacement string for newlines (default ' | ')

/// V 2.0.3
Dev.prefixName = 'MyApp'; // prefix name

/// V 2.0.2
Dev.isExeDiffColor = false; // whether execFinalFunc with different color

/// V 2.0.0 the lowest level threshold to execute the function of customFinalFunc
Dev.exeLevel = DevLevel.logWar;
Dev.customFinalFunc = (msg, level) {
  // e.g.: your custom write msg to file
  writeToFile(msg, level);
};


/// V 1.2.8 colorize multi lines
Dev.log('===================== Colorize multi lines log =====================');
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
/// V 1.2.8 special error format log
Dev.print(e, error: e, level: DevLevel.logErr);
Dev.logError('$e', error: e);
Dev.exeError('$e', error: e, colorInt: 91);

// V1.2.6 whether log on multi platform consoles like Xcode, VS Code, Terminal, etc.
Dev.isMultConsoleLog = true;

// V1.2.2
Dev.isLogShowDateTime = true; // whether log the date time
Dev.isExeWithShowLog = true; // whether execFinalFunc with showing log
Dev.isExeWithDateTime = false; // whether execFinalFunc with date time

// V1.2.1
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

// V1.2.0 Execute the custom function
Dev.exe('!!! Exec Normal');
Dev.exe('!!! Exec Colorized text Info Without log', level: DevLevel.logInf, isMultConsole: true, isLog: false, colorInt: 101);
Dev.print('Colorized text print with the given level', level: DevLevel.logWar);
// END

// then every level log func contains execFinalFunc param:
Dev.log('Colorized text log to your process of log', execFinalFunc: true);

// V1.1.6 custom function to support your process of log
// Deprecated: Use exeFinalFunc instead (customFinalFunc will be removed in future versions)
// Dev.customFinalFunc = (msg, level) {
//   writeToFile(msg, level);  
// };

## Migration Guide

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

**Infinite Recursion Prevention:** The library automatically prevents infinite recursion when `exeFinalFunc` or `customFinalFunc` calls Dev logging methods (like `Dev.exeError`, `Dev.exe`, etc.) internally.

```dart
// Safe: This won't cause infinite recursion
Dev.exeFinalFunc = (msg, level) {
  writeToFile(msg, level);
  Dev.exeError('Also log this error'); // Won't trigger exeFinalFunc again
};
```

/* Log usage: */
Dev.log('Colorized text log'); // default yellow text
Dev.logInfo('Colorized text Info'); // blue text
Dev.logSuccess('Colorized text Success', execFinalFunc: true); // green text
Dev.logWarning('Colorized text Warning'); // yellow text
Dev.logError('Colorized text Error'); // red text
Dev.logBlink('Colorized text blink', isSlow: true, isLog: true); // blink orange text

// Support to log on multi platform consoles like Xcode and VS Code
Dev.print('Dev text print', isDebug: true); // default log only on debug mode

// Others:
Dev.log('Colorized text log other customs', fileLocation: 'main.dart:90xx', colorInt: 96);

// Example: Multi-line log for better search visibility
const errorDetails = '''Error occurred:
- File: user.dart:123
- Function: validateEmail()
- Reason: Invalid format''';

// With replacement enabled (default):
Dev.logError(errorDetails); 
// Output: Error occurred: | - File: user.dart:123 | - Function: validateEmail() | - Reason: Invalid format

// Example with messy whitespace:
const messyLog = '''  Error:  
	Multiple    spaces   and	tabs
   End with spaces  ''';

// With replacement enabled - cleans up extra whitespace:
Dev.logError(messyLog);
// Output: Error: | Multiple spaces and tabs | End with spaces

// Without replacement:
Dev.isReplaceNewline = false;
Dev.logError(errorDetails);
// Output: Error occurred:
//         - File: user.dart:123
//         - Function: validateEmail()
//         - Reason: Invalid format

// Example: printOnceIfContains for one-time logging (v2.0.7+)
// Useful for preventing duplicate error logs in loops or repeated function calls
for (var i = 0; i < 100; i++) {
  // Only logs the FIRST time a message contains 'API-ERROR-500'
  Dev.logWarning('Request failed: API-ERROR-500 timeout', printOnceIfContains: 'API-ERROR-500');
  // Subsequent logs containing 'API-ERROR-500' are skipped
}

// Different keywords are independent
Dev.log('User login failed: ERROR-001', printOnceIfContains: 'ERROR-001');  // ✓ Logged
Dev.log('Database error: ERROR-002', printOnceIfContains: 'ERROR-002'); // ✓ Logged
Dev.log('Retry login: ERROR-001 again', printOnceIfContains: 'ERROR-001'); // ✗ Skipped (contains 'ERROR-001')
Dev.log('DB connection lost: ERROR-002', printOnceIfContains: 'ERROR-002'); // ✗ Skipped (contains 'ERROR-002')

// Message doesn't contain keyword - always logs
Dev.log('Normal log without error code', printOnceIfContains: 'ERROR-999'); // ✓ Logged (doesn't contain 'ERROR-999')

// Clear cache to allow re-logging
Dev.clearCachedKeys();
Dev.log('After clear: ERROR-001 can log again', printOnceIfContains: 'ERROR-001'); // ✓ Logged (cache was cleared)

// Practical use case: Log user actions only once per session
Dev.logInfo('User user-123 logged in', printOnceIfContains: 'user-123');
Dev.logInfo('User user-123 clicked button', printOnceIfContains: 'user-123'); // ✗ Skipped
Dev.logInfo('User user-456 logged in', printOnceIfContains: 'user-456'); // ✓ Logged (different user)

// Works with all log methods
Dev.logInfo('Info: token-abc expired', printOnceIfContains: 'token-abc');
Dev.logError('Error: connection-lost', printOnceIfContains: 'connection-lost');
Dev.exe('Execute: task-001 started', printOnceIfContains: 'task-001');
Dev.print('Print: session-xyz created', printOnceIfContains: 'session-xyz');

// Performance Optimization Examples (v2.0.8+)

// Mode 1: Default optimized mode (recommended for development)
Dev.useOptimizedStackTrace = true; // Uses stack_trace package (40-60% faster)
Dev.isLightweightMode = false;
Dev.logError('Development error with file location'); // Shows: (main.dart:123): Development error...

// Mode 2: Basic optimized mode (no external dependency)
Dev.useOptimizedStackTrace = false; // Uses basic string operations (10-20% faster)
Dev.isLightweightMode = false;
Dev.logWarning('Warning with basic stack trace'); // Shows: (main.dart:456): Warning...

// Mode 3: Maximum performance mode (recommended for production)
Dev.isLightweightMode = true; // Skips stack trace completely
Dev.logInfo('Production log'); // No file location shown, maximum performance

// Recommendation:
// - Development: useOptimizedStackTrace = true, isLightweightMode = false
// - Production: isLightweightMode = true (or disable Dev.enable entirely)
```

## Author

Visit my github: [janlionly](https://github.com/janlionly)<br>
Contact with me by email: janlionly@gmail.com

## Contribute
I would love you to contribute to **DevColorizedLog**

## License
**DevColorizedLog** is available under the MIT license. See the [LICENSE](https://github.com/janlionly/flutter_dev_colorized_log/blob/master/LICENSE) file for more info.