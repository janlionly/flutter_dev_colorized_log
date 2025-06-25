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
    const messyWhitespaceMsg = '  Line 1\n\t  Line 2    with    spaces  \n   Line 3\t\t';
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
}
