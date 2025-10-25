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

  test(
      'test printOnceIfContains functionality - only log once when message contains keyword',
      () {
    // Test that only logs once when message contains the specified keyword
    Dev.enable = true;
    Dev.clearCachedKeys(); // Clear any previous cached keywords

    int exeCallCount = 0;

    Dev.exeFinalFunc = (msg, level) {
      exeCallCount++;
    };

    Dev.exeLevel = DevLevel.logNor;

    // First call with message containing 'ERROR-001' should execute
    Dev.log('API request failed: ERROR-001 timeout',
        isLog: true, printOnceIfContains: 'ERROR-001', execFinalFunc: true);

    // Second call with message also containing 'ERROR-001' should be skipped
    Dev.log('Retry failed with ERROR-001 again',
        isLog: true, printOnceIfContains: 'ERROR-001', execFinalFunc: true);

    // Third call with message containing 'ERROR-001' should also be skipped
    Dev.log('Final attempt: ERROR-001 persists',
        isLog: true, printOnceIfContains: 'ERROR-001', execFinalFunc: true);

    // Fourth call with different keyword should execute
    Dev.log('Database connection ERROR-002 occurred',
        isLog: true, printOnceIfContains: 'ERROR-002', execFinalFunc: true);

    // Fifth call with keyword but message doesn't contain it - should execute
    Dev.log('This message has no error code',
        isLog: true, printOnceIfContains: 'ERROR-999', execFinalFunc: true);

    // Sixth call without printOnceIfContains should always execute
    Dev.log('Regular log without keyword check',
        isLog: true, execFinalFunc: true);

    // We should have 4 calls: first, fourth, fifth, sixth
    expect(exeCallCount, 4);

    // Clear cached keys and verify the same keyword can be printed again
    Dev.clearCachedKeys();
    exeCallCount = 0;

    Dev.log('After clear - ERROR-001 can print again',
        isLog: true, printOnceIfContains: 'ERROR-001', execFinalFunc: true);

    Dev.log('After clear - ERROR-001 second attempt skipped',
        isLog: true, printOnceIfContains: 'ERROR-001', execFinalFunc: true);

    // Should have only 1 call after clearing cache
    expect(exeCallCount, 1);

    // Test with different log methods and keywords
    exeCallCount = 0;
    Dev.clearCachedKeys();

    Dev.logInfo('User login: user-123',
        isLog: true, printOnceIfContains: 'user-123', execFinalFunc: true);
    Dev.logInfo('User action: user-123 clicked button',
        isLog: true, printOnceIfContains: 'user-123', execFinalFunc: true);
    Dev.logWarning('Warning: invalid-token detected',
        isLog: true, printOnceIfContains: 'invalid-token', execFinalFunc: true);
    Dev.logError('Error: connection-lost event',
        isLog: true,
        printOnceIfContains: 'connection-lost',
        execFinalFunc: true);
    Dev.exe('Execute: task-001 started', printOnceIfContains: 'task-001');
    Dev.exe('Execute: task-001 in progress', printOnceIfContains: 'task-001');
    Dev.print('Print: session-abc created',
        isLog: true, printOnceIfContains: 'session-abc', execFinalFunc: true);
    Dev.print('Print: session-abc active',
        isLog: true, printOnceIfContains: 'session-abc', execFinalFunc: true);

    // Should have 5 calls: user-123, invalid-token, connection-lost, task-001, session-abc (each only once)
    expect(exeCallCount, 5);

    // Clean up
    Dev.exeFinalFunc = null;
    Dev.clearCachedKeys();
  });
}
