## [2.2.0] - 18 Dec 2025

**New Features:**
* Added `Dev.isShowLevelEmojis` to control emoji display in logs (defaults to true in debug mode, false in release mode)
* Added tag-based filtering system with `Dev.isFilterByTags` and `Dev.tags` for modular development
  - Tags can be auto-detected from file path or manually specified via `tag` parameter
  - Filtering only affects console output; `exeFinalFunc` always executes
* Added `Dev.useFastPrint` for performance optimization (defaults to true in debug mode, false in release mode)
* Updated `Dev.isReplaceNewline` to default based on kDebugMode (true in debug, false in release)
* Changed `Dev.newlineReplacement` default from ` | ` to ` • ` (bullet point) for better visibility and clear separation semantics
* Optimized tag extraction to skip stack trace capture when tags not configured

## [2.1.1] - 12 Dec 2025

* Docs: Reworked README with detailed feature breakdowns, richer examples, and clearer guidance on log filtering, debouncing, and customization options.
* Docs: Added comprehensive API doc comments across `Dev` and `DevColorizedLog` methods to explain parameters, behaviors, and best practices.
* Chore: Updated package description to reflect the broader positioning as a full logging utility rather than a simple colorizer.

## [2.1.0] - 12 Dec 2025

**BREAKING CHANGES:**
* Renamed `DevLevel` enum values for clarity: `logVer` → `verbose`, `logNor` → `normal`, `logInf` → `info`, `logSuc` → `success`, `logWar` → `warn`, `logErr` → `error`, `logBlk` → `fatal`
* Renamed methods: `logBlink()` → `logFatal()`, `exeBlink()` → `exeFatal()` (old methods removed)
* Migration required: Update all `DevLevel.*` references in your code

**New Features:**
* Added `DevLevel.verbose` level with `logVerbose()` and `exeVerbose()` methods for detailed debug output (dark gray)
* Added `Dev.logLevel` property to filter console output by minimum level threshold (similar to `exeLevel` for callbacks)
* Added `logWarn()` and `exeWarn()` as recommended shorter alternatives (old `logWarning()`/`exeWarning()` methods deprecated)

**Improvements:**
* Enhanced error formatting with clearer structure: `❌ [ERROR CAPTURED]:` header with 🆔 emoji and proper indentation
* Refactored to use `DevLevel.xxx.name` internally for type safety and consistency
* Log output now displays full level names (e.g., `[📬:info&exe]`, `[🚧:warn&exe]`)

## [2.0.9] - 10 Dec 2025

* Feat: Added [debounceMs] parameter to all log methods (log, print, exe, logInfo, logSuccess, logWarning, logError, logBlink, exeInfo, exeSuccess, exeWarning, exeError, exeBlink) - throttles logs within the specified time interval in milliseconds.
* Feat: Added [debounceKey] parameter to all log methods - allows custom key for debounce identification. When provided, uses debounceKey instead of message content for debouncing, enabling debounce for logs with dynamic content (e.g., timestamps, counters).
* Feat: Added [Dev.shouldDebounce()] method to check if a log should be debounced based on the key and time interval.
* Feat: Added [Dev.clearDebounceTimestamps()] method to clear all debounce timestamps and reset the debounce state.
* Use case: Prevents log spam from rapid repeated calls (e.g., button clicks, scroll events, API requests) by discarding logs within the debounce interval.
* Example: `Dev.logWarning('Button clicked ${DateTime.now()}', debounceMs: 2000, debounceKey: 'button_click')` will only log once every 2 seconds despite dynamic timestamps.
* Fallback: When debounceKey is not provided, uses msg|devLevel|name as the debounce key for backward compatibility.

## [2.0.8] - 08 Dec 2025

* Performance: Significantly improved stack trace extraction performance (40-60% faster with optimized mode, 10-20% faster with basic mode).
* Feat: Added [isLightweightMode] static parameter - skip stack trace capture completely for maximum performance in production environments (file location logging is disabled when enabled).
* Feat: Added [useOptimizedStackTrace] static parameter (default: true) - uses stack_trace package for better performance. Set to false to use basic string operations.
* Refactor: Unified file location extraction logic with new [_getFileLocation()] and [_getFileLocationBasic()] internal methods, replacing duplicated code across all log methods.
* Dependency: Added stack_trace package (^1.11.0) for optimized stack trace parsing.

## [2.0.7] - 25 Oct 2025

* Feat: Added [printOnceIfContains] parameter to all log methods (log, print, exe, logInfo, logSuccess, logWarning, logError, logBlink, exeInfo, exeSuccess, exeWarning, exeError, exeBlink) - only prints the first log message containing the specified keyword, subsequent logs with the same keyword are skipped.
* Feat: Added [Dev.clearCachedKeys()] method to clear all cached keywords and allow re-logging.
* Use case: Prevents duplicate error logs in loops or repeated function calls by checking if message contains specified keyword (e.g., error codes, user IDs, session identifiers).
* Example: `Dev.logError('API failed: ERROR-001', printOnceIfContains: 'ERROR-001')` will only log the first occurrence.

## [2.0.6] - 26 Jun 2025

* Breaking: Renamed [customFinalFunc] to [exeFinalFunc] for better naming consistency. The old [customFinalFunc] is now deprecated but still works for backward compatibility. It will be removed in future versions. Please migrate to [exeFinalFunc].
* Feat: Added priority logic - [exeFinalFunc] takes priority over [customFinalFunc] when both are set.
* Safety: Added infinite recursion prevention - prevents stack overflow when [exeFinalFunc] or [customFinalFunc] calls Dev logging methods internally.

## [2.0.5] – 26 Jun 2025

* Docs: Update README.md and dart formatter.

## [2.0.4] – 26 Jun 2025

* Fixed: Color maps now dynamically reflect changes to defaultColorInt, isMultConsoleLog, and isExeDiffColor by using getters instead of static finals.
* Feat: Added optional newline replacement in logs (isReplaceNewline, default true) for improved console search readability.

## [2.0.3] - 29 Mar 2025

* Feat: Add static param [prefixName] to support the prefix name.

## [2.0.2] - 28 Mar 2025

* Feat: Add static param [isExeDiffColor] decides whether execFinalFunc log with different color and changed prefix name.

## [2.0.1] - 28 Mar 2025

* Style: Adjust log format.

## [2.0.0] - 28 Mar 2025

* Feat: Add the lowest level threshold to execute the function of customFinalFunc.

## [1.2.8] - 28 Mar 2025

* Feat: Add colorize multi lines log and special error format log.

## [1.2.7] - 24 Mar 2025

* Docs: Update README.md and dart formatter.

## [1.2.6] - 23 Mar 2025

* Feat: Add global static param [isMultConsoleLog] to support multiple console logs.

## [1.2.5] - 25 Feb 2025

* Feat: Adjust dart sdk and format.

## [1.2.4] - 22 Jan 2025

* Feat: Set default log is false.

## [1.2.3] - 2 Jan 2025

* Feat: Adjust format.

## [1.2.2] - 2 Jan 2025

* Feat: Add static params [isLogShowDateTime], [isExeWithDateTime], [isExeWithShowLog].

## [1.2.1] - 13 Dec 2024

* Feat: Add static exec custom functions with the log level.

## [1.2.0] - 12 Dec 2024

* Feat: Add static exec custom function and add param [level] decides the log level.
  
## [1.1.6] - 29 Nov 2024

* Feat: Add custom function to support your process of log.

## [1.1.5] - 5 Aug 2024

* Feat: print method param type updated.

## [1.1.4] - 5 Aug 2024

* Feat: Add static param [isDebugPrint] decides whether printing only on debug mode.

## [1.1.3] - 5 Aug 2024

* Feat: Param [isLog] set to true to log anyway.

## [1.1.2] - 5 Aug 2024

* Feat: Add print to support log showing on multiple consoles.
  
## [1.1.1] - 3 Aug 2024

* Feat: Adjust code level.

## [1.1.0] - 2 Aug 2024

* Fixed: the log of the file location is wrong.

## [1.0.2] - 2 Aug 2024

* Feat: add log name symbols and more parameters.

## [1.0.1] - 3 Nov 2023

* Fixed: the global log enable.

## [1.0.0] - 2 Nov 2023

* Done: A Flutter package for logging colorized text in developer mode.
