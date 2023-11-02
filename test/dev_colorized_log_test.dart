import 'package:flutter_test/flutter_test.dart';

import 'package:dev_colorized_log/dev_colorized_log.dart';

void main() {
  test('adds one to input values', () {
    Dev.log('Colorized text log');
    Dev.logInfo('Colorized text Info');
    Dev.logSuccess('Colorized text Success');
    Dev.logWarning('Colorized text Warning');
    Dev.logError('Colorized text Error');
    Dev.logBlink('Colorized text blink', isSlow: true, isLog: true);
    
    Dev.logCustom('Colorized text custom with Custom: 41', colorInt: 41, fileInfo: null);
  });
}
