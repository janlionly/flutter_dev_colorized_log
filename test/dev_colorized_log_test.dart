import 'package:flutter_test/flutter_test.dart';

import 'package:dev_colorized_log/dev_colorized_log.dart';

void main() {
  test('adds one to input values', () {
    Dev.logVerbose('Colorized text Verbose');
    Dev.log('Colorized text log');
    Dev.logInfo('Colorized text Info');
    Dev.logSuccess('Colorized text Success');
    Dev.logWarn('Colorized text Warning');
    Dev.logError('Colorized text Error');
    Dev.logFatal('Colorized text fatal', isLog: true);
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
    Dev.exeLevel = DevLevel.normal;

    String? capturedMsg;
    DevLevel? capturedLevel;

    Dev.exeFinalFunc = (msg, level) {
      capturedMsg = msg;
      capturedLevel = level;
    };

    Dev.exe('Test exeFinalFunc', level: DevLevel.info);
    expect(capturedMsg?.contains('Test exeFinalFunc'), true);
    expect(capturedLevel, DevLevel.info);

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
        level: DevLevel.warn);
    expect(
        deprecatedCapturedMsg
            ?.contains('Test customFinalFunc backward compatibility'),
        true);
    expect(deprecatedCapturedLevel, DevLevel.warn);

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

    Dev.exe('Test recursion prevention', level: DevLevel.error);

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

    Dev.exeLevel = DevLevel.normal;

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
    Dev.logWarn('Warning: invalid-token detected',
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

  test('test debounceMs functionality - throttle logs within time interval',
      () async {
    // Test debounce functionality - logs within the specified interval should be discarded
    Dev.enable = true;
    Dev.clearDebounceTimestamps(); // Clear any previous debounce state

    int logCallCount = 0;

    Dev.exeFinalFunc = (msg, level) {
      logCallCount++;
    };

    Dev.exeLevel = DevLevel.normal;

    // Test 1: Basic debounce - rapid calls within 500ms should be throttled
    Dev.log('Debounce test 1',
        isLog: true, debounceMs: 500, execFinalFunc: true);
    await Future.delayed(const Duration(milliseconds: 100));
    Dev.log('Debounce test 1',
        isLog: true, debounceMs: 500, execFinalFunc: true); // Should be skipped
    await Future.delayed(const Duration(milliseconds: 100));
    Dev.log('Debounce test 1',
        isLog: true, debounceMs: 500, execFinalFunc: true); // Should be skipped

    // Only the first call should execute
    expect(logCallCount, 1);

    // Wait for debounce period to expire
    await Future.delayed(const Duration(milliseconds: 400));
    Dev.log('Debounce test 1',
        isLog: true,
        debounceMs: 500,
        execFinalFunc: true); // Should execute after interval
    expect(logCallCount, 2);

    // Test 2: Different messages should have independent debounce
    logCallCount = 0;
    Dev.clearDebounceTimestamps();

    Dev.log('Message A', isLog: true, debounceMs: 300, execFinalFunc: true);
    Dev.log('Message B', isLog: true, debounceMs: 300, execFinalFunc: true);
    Dev.log('Message A',
        isLog: true, debounceMs: 300, execFinalFunc: true); // Should be skipped
    Dev.log('Message B',
        isLog: true, debounceMs: 300, execFinalFunc: true); // Should be skipped

    // Both unique messages should execute once
    expect(logCallCount, 2);

    // Test 3: Different log levels should have independent debounce
    logCallCount = 0;
    Dev.clearDebounceTimestamps();

    Dev.logInfo('Same message',
        isLog: true, debounceMs: 300, execFinalFunc: true);
    Dev.logWarn('Same message',
        isLog: true, debounceMs: 300, execFinalFunc: true);
    Dev.logError('Same message',
        isLog: true, debounceMs: 300, execFinalFunc: true);

    // All different levels should execute
    expect(logCallCount, 3);

    // Test 4: Zero debounceMs should not throttle
    logCallCount = 0;
    Dev.clearDebounceTimestamps();

    Dev.log('No debounce', isLog: true, debounceMs: 0, execFinalFunc: true);
    Dev.log('No debounce', isLog: true, debounceMs: 0, execFinalFunc: true);
    Dev.log('No debounce', isLog: true, debounceMs: 0, execFinalFunc: true);

    // All calls should execute
    expect(logCallCount, 3);

    // Test 5: Test with exe methods
    logCallCount = 0;
    Dev.clearDebounceTimestamps();

    Dev.exe('Exe debounce test', debounceMs: 400);
    await Future.delayed(const Duration(milliseconds: 100));
    Dev.exe('Exe debounce test', debounceMs: 400); // Should be skipped
    expect(logCallCount, 1);

    await Future.delayed(const Duration(milliseconds: 350));
    Dev.exe('Exe debounce test', debounceMs: 400); // Should execute
    expect(logCallCount, 2);

    // Test 6: Test with print method
    logCallCount = 0;
    Dev.clearDebounceTimestamps();

    Dev.print('Print debounce test',
        isLog: true, debounceMs: 300, execFinalFunc: true);
    Dev.print('Print debounce test',
        isLog: true, debounceMs: 300, execFinalFunc: true); // Should be skipped
    expect(logCallCount, 1);

    await Future.delayed(const Duration(milliseconds: 350));
    Dev.print('Print debounce test',
        isLog: true, debounceMs: 300, execFinalFunc: true); // Should execute
    expect(logCallCount, 2);

    // Test 7: Test specific log methods
    logCallCount = 0;
    Dev.clearDebounceTimestamps();

    Dev.logSuccess('Success msg',
        isLog: true, debounceMs: 200, execFinalFunc: true);
    Dev.logSuccess('Success msg',
        isLog: true, debounceMs: 200, execFinalFunc: true); // Skipped
    expect(logCallCount, 1);

    Dev.exeInfo('Info exe', debounceMs: 200);
    Dev.exeInfo('Info exe', debounceMs: 200); // Skipped
    expect(logCallCount, 2);

    Dev.exeWarn('Warning exe', debounceMs: 200);
    Dev.exeError('Error exe', debounceMs: 200);
    expect(logCallCount, 4);

    // Clean up
    Dev.exeFinalFunc = null;
    Dev.clearDebounceTimestamps();
  });

  test('test debounceKey functionality - use custom key for dynamic messages',
      () async {
    // Test that debounceKey allows debouncing messages with dynamic content
    Dev.enable = true;
    Dev.clearDebounceTimestamps();

    int logCallCount = 0;

    Dev.exeFinalFunc = (msg, level) {
      logCallCount++;
    };

    Dev.exeLevel = DevLevel.normal;

    // Test 1: Messages with dynamic content but same debounceKey should be debounced
    Dev.log('Button clicked at ${DateTime.now()}',
        isLog: true,
        debounceMs: 500,
        debounceKey: 'button_click',
        execFinalFunc: true);

    await Future.delayed(const Duration(milliseconds: 100));

    Dev.log('Button clicked at ${DateTime.now()}',
        isLog: true,
        debounceMs: 500,
        debounceKey: 'button_click',
        execFinalFunc: true); // Should be skipped - same debounceKey

    // Only first should execute
    expect(logCallCount, 1);

    // Test 2: After debounce period, should log again
    await Future.delayed(const Duration(milliseconds: 450));

    Dev.log('Button clicked at ${DateTime.now()}',
        isLog: true,
        debounceMs: 500,
        debounceKey: 'button_click',
        execFinalFunc: true); // Should execute - debounce period expired

    expect(logCallCount, 2);

    // Test 3: Different debounceKey should not interfere
    logCallCount = 0;
    Dev.clearDebounceTimestamps();

    Dev.logWarn('Event A at ${DateTime.now()}',
        debounceMs: 300, debounceKey: 'event_a', execFinalFunc: true);

    Dev.logWarn('Event B at ${DateTime.now()}',
        debounceMs: 300, debounceKey: 'event_b', execFinalFunc: true);

    Dev.logWarn('Event A at ${DateTime.now()}',
        debounceMs: 300,
        debounceKey: 'event_a',
        execFinalFunc: true); // Skipped - same key as first

    Dev.logWarn('Event B at ${DateTime.now()}',
        debounceMs: 300,
        debounceKey: 'event_b',
        execFinalFunc: true); // Skipped - same key as second

    // Both unique keys should execute once
    expect(logCallCount, 2);

    // Test 4: debounceKey with counter in message
    logCallCount = 0;
    Dev.clearDebounceTimestamps();

    for (int i = 0; i < 5; i++) {
      Dev.exeInfo('API request attempt $i',
          debounceMs: 400, debounceKey: 'api_request');
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Only first should execute (all have same debounceKey)
    expect(logCallCount, 1);

    // Test 5: Mixing debounceKey with regular debounce
    logCallCount = 0;
    Dev.clearDebounceTimestamps();

    // With debounceKey
    Dev.log('Dynamic message 1',
        debounceMs: 300, debounceKey: 'custom_key', execFinalFunc: true);

    Dev.log('Dynamic message 2',
        debounceMs: 300,
        debounceKey: 'custom_key',
        execFinalFunc: true); // Skipped - same debounceKey

    // Without debounceKey (uses msg as part of key)
    Dev.log('Static message', debounceMs: 300, execFinalFunc: true);

    Dev.log('Static message',
        debounceMs: 300, execFinalFunc: true); // Skipped - same msg

    // Should have 2 calls (one for custom_key, one for Static message)
    expect(logCallCount, 2);

    // Test 6: Real-world scenario - scroll position logging
    logCallCount = 0;
    Dev.clearDebounceTimestamps();

    // Simulate rapid scroll events (5 events within 100ms)
    for (double offset = 0; offset < 500; offset += 100) {
      Dev.logInfo('Scroll position: $offset px',
          debounceMs: 300, debounceKey: 'scroll_event', execFinalFunc: true);
      await Future.delayed(const Duration(milliseconds: 20));
    }

    // Only first scroll should log (all within 300ms with same debounceKey)
    expect(logCallCount, 1);

    // Test 7: Works with all log methods
    logCallCount = 0;
    Dev.clearDebounceTimestamps();

    Dev.log('Log ${DateTime.now()}',
        debounceMs: 200, debounceKey: 'test_key', execFinalFunc: true);

    Dev.logInfo('Info ${DateTime.now()}',
        debounceMs: 200, debounceKey: 'test_key', execFinalFunc: true);

    Dev.logWarn('Warning ${DateTime.now()}',
        debounceMs: 200, debounceKey: 'test_key', execFinalFunc: true);

    // Different levels but same debounceKey - should all be independent by level
    // Each level should log once
    expect(logCallCount, 3);

    // Clean up
    Dev.exeFinalFunc = null;
    Dev.clearDebounceTimestamps();
  });

  test('test logLevel functionality - filter console output below threshold',
      () {
    // Note: logLevel only filters console output, not execFinalFunc execution
    // This test verifies that logs are still processed (execFinalFunc called)
    // but console output is filtered based on logLevel
    Dev.enable = true;

    int execCallCount = 0;

    Dev.exeFinalFunc = (msg, level) {
      execCallCount++;
    };

    Dev.exeLevel = DevLevel.verbose; // Execute all levels

    // Test 1: logLevel = info - verbose and normal logs still execute callbacks
    // but won't print to console
    Dev.logLevel = DevLevel.info;
    execCallCount = 0;

    Dev.logVerbose('Verbose log',
        execFinalFunc: true); // Console filtered, but callback executes
    Dev.log('Normal log',
        execFinalFunc: true); // Console filtered, but callback executes
    Dev.logInfo('Info log',
        execFinalFunc: true); // Console shown, callback executes
    Dev.logWarn('Warning log',
        execFinalFunc: true); // Console shown, callback executes
    Dev.logError('Error log',
        execFinalFunc: true); // Console shown, callback executes

    // All 5 callbacks execute (logLevel doesn't block execFinalFunc)
    expect(execCallCount, 5);

    // Test 2: Verify logs are created even when filtered from console
    Dev.logLevel = DevLevel.warn;
    execCallCount = 0;

    // These still trigger execFinalFunc even though console output is filtered
    Dev.logVerbose('Verbose', execFinalFunc: true);
    Dev.log('Normal', execFinalFunc: true);
    Dev.logInfo('Info', execFinalFunc: true);
    Dev.logSuccess('Success', execFinalFunc: true);
    Dev.logWarn('Warning', execFinalFunc: true);
    Dev.logError('Error', execFinalFunc: true);
    Dev.logFatal('Fatal', execFinalFunc: true);

    // All 7 callbacks execute
    expect(execCallCount, 7);

    // Test 3: Combine logLevel and exeLevel for dual filtering
    // logLevel filters console output, exeLevel filters callback execution
    Dev.logLevel = DevLevel.warn; // Console: only warning+
    Dev.exeLevel = DevLevel.error; // Callback: only error+
    execCallCount = 0;

    Dev.logVerbose('Verbose',
        execFinalFunc: true); // Console: filtered, Callback: filtered
    Dev.logWarn('Warning',
        execFinalFunc:
            true); // Console: shown, Callback: filtered (below exeLevel)
    Dev.logError('Error',
        execFinalFunc: true); // Console: shown, Callback: executed
    Dev.logFatal('Fatal',
        execFinalFunc: true); // Console: shown, Callback: executed

    // Only 2 callbacks execute (error and fatal meet exeLevel threshold)
    expect(execCallCount, 2);

    // Test 4: Test without execFinalFunc - just verify no errors
    Dev.logLevel = DevLevel.error;

    Dev.logVerbose('Verbose without callback'); // Console filtered
    Dev.log('Normal without callback'); // Console filtered
    Dev.logError('Error without callback'); // Console shown

    // No errors should occur

    // Clean up - reset to default
    Dev.logLevel = DevLevel.verbose;
    Dev.exeLevel = DevLevel.warn;
    Dev.exeFinalFunc = null;
  });
}
