# Dev Colorized Log

[![pub package](https://img.shields.io/pub/v/image_color_builder.svg)](https://github.com/janlionly/flutter_dev_colorized_log)<a href="https://github.com/janlionly/flutter_dev_colorized_log"><img src="https://img.shields.io/github/stars/janlionly/flutter_dev_colorized_log.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>

A Flutter package for logging colorized text in developer mode.

## Usage

See examples to `/example` folder.

```dart
// Global settings:
Dev.enable = true;					// whether log msg
Dev.isLogFileInfo = true;			// whether log the location file info
Dev.defaultColorInt = 33;			// default color text, int value from 0 to 107

// Log usage:
Dev.log('Colorized text log');				// default yellow text
Dev.logInfo('Colorized text Info'); 		// blue text
Dev.logSuccess('Colorized text Success');   // green text
Dev.logWarning('Colorized text Warning');   // yellow text
Dev.logError('Colorized text Error'); 		// red text
Dev.logBlink('Colorized text blink', isSlow: true, isLog: true); // blink orange text
Dev.logCustom('Colorized text custom with Custom: 41', colorInt: 41, fileInfo: null); // custom color text
```

## Author

Visit my github: [janlionly](https://github.com/janlionly)<br>
Contact with me by email: janlionly@gmail.com

## Contribute
I would love you to contribute to **DevColorizedLog**

## License
**DevColorizedLog** is available under the MIT license. See the [LICENSE](https://github.com/janlionly/flutter_dev_colorized_log/blob/master/LICENSE) file for more info.
