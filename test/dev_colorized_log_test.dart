import 'package:flutter_test/flutter_test.dart';

import 'package:dev_colorized_log/dev_colorized_log.dart';

void main() {
  test('adds one to input values', () {
    Dev.log('Colorized text log');
    Dev.logInfo('Colorized text Info');
    Dev.logSuccess('Colorized text Success');
    Dev.logWarning('Colorized text Warning');
    Dev.logError('Colorized text Error');
    Dev.logBlink('Colorized text blink', isLog: true);
  });

  test('test defaultColorInt dynamic update', () {
    // Verify that color mapping updates dynamically after static variables are modified
    Dev.enable = true;
    Dev.isMultConsoleLog = true;
    Dev.defaultColorInt = null;
    Dev.log('Test defaultColorInt null', isLog: true);

    Dev.defaultColorInt = 31;
    Dev.log('Test defaultColorInt\n 31', isLog: true);

    Dev.defaultColorInt = 35;
    Dev.log('Test defaultColorInt 35', isLog: true);

    Dev.defaultColorInt = null;
    Dev.log('Test isMultConsoleLog true', isLog: true);

    Dev.isExeDiffColor = true;
    Dev.log('Test isExeDiffColor true', isLog: true, execFinalFunc: true);

    Dev.isExeDiffColor = false;
    Dev.log('Test isExeDiffColor false', isLog: true, execFinalFunc: true);
  });

  test('test newline replacement', () {
    // Test newline replacement functionality
    Dev.enable = true;
    Dev.isMultConsoleLog = true;
    Dev.isReplaceNewline = true;
    Dev.newlineReplacement = ' | ';

    const multiLineMsg = 'Line 1\nLine 2\nLine 3';
    Dev.log(multiLineMsg, isLog: true);

    // Test whitespace cleanup functionality
    const messyWhitespaceMsg =
        '  Line 1\n\t  Line 2    with    spaces  \n   Line 3\t\t';
    Dev.log(messyWhitespaceMsg, isLog: true);

    // Test disabling newline replacement
    Dev.isReplaceNewline = false;
    Dev.log(multiLineMsg, isLog: true);
    Dev.log(messyWhitespaceMsg, isLog: true);

    // Test custom replacement character
    Dev.isReplaceNewline = true;
    Dev.newlineReplacement = ' >> ';
    Dev.log(multiLineMsg, isLog: true);
    Dev.log(messyWhitespaceMsg, isLog: true);
  });

  test('test exeFinalFunc and backward compatibility', () {
    // Test new exeFinalFunc
    Dev.enable = true;
    Dev.exeLevel = DevLevel.logNor;

    String? capturedMsg;
    DevLevel? capturedLevel;

    Dev.exeFinalFunc = (msg, level) {
      capturedMsg = msg;
      capturedLevel = level;
    };

    Dev.exe('Test exeFinalFunc', level: DevLevel.logInf);
    expect(capturedMsg?.contains('Test exeFinalFunc'), true);
    expect(capturedLevel, DevLevel.logInf);

    // Test backward compatibility with deprecated customFinalFunc
    String? deprecatedCapturedMsg;
    DevLevel? deprecatedCapturedLevel;

    Dev.exeFinalFunc = null; // Clear new function
    // ignore: deprecated_member_use
    Dev.customFinalFunc = (msg, level) {
      deprecatedCapturedMsg = msg;
      deprecatedCapturedLevel = level;
    };

    Dev.exe('Test customFinalFunc backward compatibility',
        level: DevLevel.logWar);
    expect(
        deprecatedCapturedMsg
            ?.contains('Test customFinalFunc backward compatibility'),
        true);
    expect(deprecatedCapturedLevel, DevLevel.logWar);

    // Test infinite recursion prevention
    int callCount = 0;

    Dev.exeFinalFunc = (msg, level) {
      callCount++;
      // This would cause infinite recursion without protection
      Dev.exeError('Recursive call attempt exeFinalFunc $callCount');
      Dev.exeError('Recursive call attempt exeFinalFunc2 $callCount');
      Dev.exeError('Recursive call attempt exeFinalFunc3 $callCount');
    };

    Dev.customFinalFunc = (msg, level) {
      callCount++;
      // This would cause infinite recursion without protection
      Dev.exeError('Recursive call attempt customFinalFunc $callCount');
    };

    Dev.exe('Test recursion prevention', level: DevLevel.logErr);

    // The callback should only be called once due to recursion prevention
    expect(callCount, 1);

    // Clean up
    Dev.exeFinalFunc = null;
    // ignore: deprecated_member_use
    Dev.customFinalFunc = null;
  });
}
