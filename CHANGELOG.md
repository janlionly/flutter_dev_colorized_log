## [1.0.0] - 2 Nov 2023

* Done: A Flutter package for logging colorized text in developer mode.

## [1.0.1] - 3 Nov 2023

* Fixed: the global log enable.

## [1.0.2] - 2 Aug 2024

* Feat: add log name symbols and more parameters.

## [1.1.0] - 2 Aug 2024

* Fixed: the log of the file location is wrong.

## [1.1.1] - 3 Aug 2024

* Feat: Adjust code level.

## [1.1.2] - 5 Aug 2024

* Feat: Add print to support log showing on multiple consoles.
  
## [1.1.3] - 5 Aug 2024

* Feat: Param [isLog] set to true to log anyway.

## [1.1.4] - 5 Aug 2024

* Feat: Add static param [isDebugPrint] decides whether printing only on debug mode.

## [1.1.5] - 5 Aug 2024

* Feat: print method param type updated.

## [1.1.6] - 29 Nov 2024

* Feat: Add custom function to support your process of log.

## [1.2.0] - 12 Dec 2024

* Feat: Add static exec custom function and add param [level] decides the log level.
  
## [1.2.1] - 13 Dec 2024

* Feat: Add static exec custom functions with the log level.

## [1.2.2] - 2 Jan 2025

* Feat: Add static params [isLogShowDateTime], [isExeWithDateTime], [isExeWithShowLog].

## [1.2.3] - 2 Jan 2025

* Feat: Adjust format.

## [1.2.4] - 22 Jan 2025

* Feat: Set default log is false.

## [1.2.5] - 25 Feb 2025

* Feat: Adjust dart sdk and format.

## [1.2.6] - 23 Mar 2025

* Feat: Add global static param [isMultConsoleLog] to support multiple console logs.

## [1.2.7] - 24 Mar 2025

* Docs: Update README.md and dart formatter.

## [1.2.8] - 28 Mar 2025

* Feat: Add colorize multi lines log and special error format log.

## [2.0.0] - 28 Mar 2025

* Feat: Add the lowest level threshold to execute the function of customFinalFunc.

## [2.0.1] - 28 Mar 2025

* Style: Adjust log format.

## [2.0.2] - 28 Mar 2025

* Feat: Add static param [isExeDiffColor] decides whether execFinalFunc log with different color and changed prefix name.

## [2.0.3] - 29 Mar 2025

* Feat: Add static param [prefixName] to support the prefix name.

## [2.0.4] – 26 Jun 2025

* Fixed: Color maps now dynamically reflect changes to defaultColorInt, isMultConsoleLog, and isExeDiffColor by using getters instead of static finals.
* Feat: Added optional newline replacement in logs (isReplaceNewline, default true) for improved console search readability.

## [2.0.5] – 26 Jun 2025

* Docs: Update README.md and dart formatter.

## [2.0.6] - 26 Jun 2025

* Breaking: Renamed [customFinalFunc] to [exeFinalFunc] for better naming consistency. The old [customFinalFunc] is now deprecated but still works for backward compatibility. It will be removed in future versions. Please migrate to [exeFinalFunc].
* Feat: Added priority logic - [exeFinalFunc] takes priority over [customFinalFunc] when both are set.
* Safety: Added infinite recursion prevention - prevents stack overflow when [exeFinalFunc] or [customFinalFunc] calls Dev logging methods internally.

