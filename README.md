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
Dev.customFinalFunc = (msg) {
	// e.g.: your custom write msg to file  
  writeToFile(msg);
};

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
```

## Author

Visit my github: [janlionly](https://github.com/janlionly)<br>
Contact with me by email: janlionly@gmail.com

## Contribute
I would love you to contribute to **DevColorizedLog**

## License
**DevColorizedLog** is available under the MIT license. See the [LICENSE](https://github.com/janlionly/flutter_dev_colorized_log/blob/master/LICENSE) file for more info.
