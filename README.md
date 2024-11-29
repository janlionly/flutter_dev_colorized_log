# Dev Colorized Log

[![pub package](https://img.shields.io/pub/v/image_color_builder.svg)](https://github.com/janlionly/flutter_dev_colorized_log)<a href="https://github.com/janlionly/flutter_dev_colorized_log"><img src="https://img.shields.io/github/stars/janlionly/flutter_dev_colorized_log.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>

A Flutter package for logging colorized text in developer mode.

## Usage

See examples to `/example` folder, more please run example project.

```dart
/* Global settings:*/
Dev.enable = true; // whether log msg
Dev.isLogFileLocation = true; // whether log the location file info
Dev.defaultColorInt = 0; // default color text, int value from 0 to 107
Dev.isDebugPrint = true; // Dev.print whether only log on debug mode

// custom function to support your process of log
Dev.customFinalFunc = (msg) {
	// e.g.: your custom write msg to file  
  writeToFile(msg);
};
// then every level log func contains execFinalFunc param:
Dev.log('Colorized text log to your process of log', execFinalFunc: true);

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
