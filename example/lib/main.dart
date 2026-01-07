import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:dev_colorized_log/dev_colorized_log.dart';

import 'tag_demo_page.dart';

void causeError() {
  _layerA();
}

void _layerA() => _layerB();
void _layerB() => _layerC();
void _layerC() =>
    throw Exception("🔥 Manually triggered exception (with full stack trace)");

void main() {
  Dev.enable = true;
  Dev.isMultConsoleLog = true;
  Dev.isDebugPrint = true;
  Dev.isLogFileLocation = true;
  Dev.isExeDiffColor = false;
  Dev.prefixName = 'MyApp-';
  Dev.isShowLevelEmojis = false;
  Dev.isReplaceNewline = false;

  FlutterError.onError = (FlutterErrorDetails details) {
    Dev.logError('dev_colorized_log:',
        error: details.exception, stackTrace: details.stack);
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    Dev.logError('dev_colorized_log:', error: error, stackTrace: stack);
    return true;
  };
  runApp(const MyApp());

  try {
    causeError();
  } catch (e, s) {
    Dev.exeFatal('Caught exception:', error: e, stackTrace: s);
  }
}

class UITextView extends StatefulWidget {
  final String initialText;
  final TextStyle? textStyle;

  const UITextView({
    Key? key,
    this.initialText = "",
    this.textStyle,
  }) : super(key: key);

  @override
  UITextViewState createState() => UITextViewState();
}

class UITextViewState extends State<UITextView> {
  // Performance optimization: Use list instead of concatenating strings
  // This eliminates the need to copy the entire string on each append
  final List<String> _logEntries = [];
  final ScrollController _scrollController = ScrollController();

  // Limit maximum number of log entries to prevent unbounded memory growth
  // Old entries are automatically removed when limit is exceeded
  static const int maxLogEntries = 1000;

  @override
  void initState() {
    super.initState();
    if (widget.initialText.isNotEmpty) {
      _logEntries.add(widget.initialText);
    }
  }

  void appendText(String newText) {
    setState(() {
      _logEntries.add(newText);

      // Automatically remove old entries when limit is exceeded
      // This prevents memory leak in long-running applications
      if (_logEntries.length > maxLogEntries) {
        _logEntries.removeRange(0, _logEntries.length - maxLogEntries);
      }
    });

    // Performance optimization: Use jumpTo instead of animateTo
    // This eliminates animation overhead and prevents animation stacking
    // in high-frequency logging scenarios
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      // Performance optimization: Use ListView.builder for virtual scrolling
      // Only visible items are rendered, dramatically improving performance
      // with large numbers of log entries (1000+ entries)
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _logEntries.length,
        itemBuilder: (context, index) {
          return Text(
            _logEntries[index],
            style: widget.textStyle ?? const TextStyle(fontSize: 16.0),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _debounceClickCount = 0;
  final GlobalKey<UITextViewState> textViewKey = GlobalKey<UITextViewState>();

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter = (_counter + 1) % 108;
    });
    Dev.log('==========================Click to Log========================');
    Dev.log('Colorized text custom with colorInt-->: $_counter',
        colorInt: _counter, execFinalFunc: true, level: DevLevel.warn);
  }

  void _testDebounce() {
    setState(() {
      _debounceClickCount++;
    });
    // This log will be debounced - rapid clicks within 2 seconds will be ignored
    // Using debounceKey because message contains dynamic _debounceClickCount
    Dev.logWarn(
        'Debounce Test Button Clicked (Count: $_debounceClickCount) at ${DateTime.now()} - Try clicking rapidly!',
        debounceMs: 10000,
        debounceKey: 'test_button_click',
        execFinalFunc: true);
  }

  void printCustomText() {
    for (int i = 0; i < 108; i++) {
      Dev.log('Colorized text custom with colorInt: $i', colorInt: i);
    }
  }

  @override
  void initState() {
    super.initState();

    // Dev.defaultColorInt = 97;

    Dev.exeLevel = DevLevel.warn;
    Dev.logLevel = DevLevel.verbose; // Show all logs (default)
    Dev.exeFinalFunc = (msg, level) {
      textViewKey.currentState?.appendText('${level.name}: $msg');
    };
    Dev.isLogShowDateTime = true;
    Dev.isExeWithShowLog = true;
    Dev.isExeWithDateTime = false;

    /// Performance optimization: Use fast print mode for faster console output
    /// Defaults to true in debug mode (kDebugMode), false in release mode
    /// Set to true to use print() instead of debugPrint() - faster but may lose logs
    /// Set to false to use debugPrint() - slower but safer
    // Dev.useFastPrint = true; // Override default if needed (defaults to true in debug mode)

    /// V 2.2.0 Emoji display control demo
    /// Defaults to true in debug mode, false in release mode
    Dev.log(
        '===================== Emoji Display Control Demo =====================');

    // With emojis (default in debug mode)
    Dev.isShowLevelEmojis = true;
    Dev.log('--- With Emojis Enabled (default in debug mode) ---');
    Dev.logVerbose('Verbose log with emoji');
    Dev.logInfo('Info log with emoji');
    Dev.logSuccess('Success log with emoji');
    Dev.logWarn('Warning log with emoji');
    Dev.logError('Error log with emoji');
    Dev.logFatal('Fatal log with emoji');

    // Without emojis (default in release mode)
    Dev.isShowLevelEmojis = false;
    Dev.log('--- With Emojis Disabled (default in release mode) ---');
    Dev.logVerbose('Verbose log without emoji');
    Dev.logInfo('Info log without emoji');
    Dev.logSuccess('Success log without emoji');
    Dev.logWarn('Warning log without emoji');
    Dev.logError('Error log without emoji');
    Dev.logFatal('Fatal log without emoji');

    // Reset to default (with emojis)
    Dev.isShowLevelEmojis = true;

    /// V 2.2.0 newline replacement for better search visibility
    /// Defaults to true in debug mode (kDebugMode), false in release mode
    // Dev.isReplaceNewline = true; // default is true in debug mode
    // Dev.newlineReplacement = ' | '; // Override default (' → ') for this demo

    Dev.log(
        '===================== Newline Replacement Demo =====================');
    const multiLineExample = '''Error occurred at:
    - File: user.dart line 123
    - Function: validateUser()
    - Reason: Invalid email format''';

    Dev.logError('Multi-line error with replacement:\n$multiLineExample');

    // Demo with messy whitespace
    const messyExample = '''  Error:  
	Multiple    spaces   and	tabs
   End with spaces  ''';

    Dev.logWarn('Messy whitespace cleaned up:\n$messyExample');

    // Disable newline replacement to show difference
    // Dev.isReplaceNewline = false;
    Dev.logWarn('Multi-line warning without replacement:\n$multiLineExample');

    // Re-enable with custom replacement character
    // Dev.isReplaceNewline = true;
    Dev.newlineReplacement = ' >> ';
    Dev.logWarn(
        'Multi-line warning with custom replacement:\n$multiLineExample');

    // Reset to default
    Dev.newlineReplacement = ' • ';

    /// V 1.2.8 colorize multi lines
    Dev.log('===================== Multi lines log =====================');
    const multiLines = '''
    ❌ [ERROR CAPTURED]:
      🆔 Error ID: abc-123-def
      🕒 Time: 2025-12-12 10:30:45
      📛 Type: NetworkException
      💥 Message: Connection timeout after 30s
      📚 Stack Trace:
      #0 fetchData (network.dart:42:5)
      #1 main (main.dart:12:3)
    ''';
    Dev.logError(multiLines);
    // Dev.isReplaceNewline = false;
    Dev.logError(multiLines);

    Dev.log('==========================All Color Log========================');
    printCustomText();

    Dev.log('==========================Log Level Log========================',
        name: 'logLev');
    Dev.logVerbose('Colorized text Verbose (detailed debug info)');
    Dev.log('Colorized text log', fileLocation: 'main.dart:90xx---------');
    Dev.logInfo('Colorized text Info');
    Dev.logSuccess('Colorized text Success');
    Dev.logWarn('Colorized text Warning');
    Dev.logError('Colorized text Error');
    Dev.logFatal('Colorized text fatal');
    Dev.log(
        '==========================Log Level Log End ======================',
        isLog: true);

    Dev.print(
        '==========================Print Level Log========================',
        name: 'logLev');
    Dev.print('Colorized text Verbose', level: DevLevel.verbose);
    Dev.print('Colorized text log', level: DevLevel.normal);
    Dev.print('Colorized text Info', level: DevLevel.info);
    Dev.print('Colorized text Success', level: DevLevel.success);
    Dev.print('Colorized text Warning', level: DevLevel.warn);
    Dev.print('Colorized text Error', level: DevLevel.error);
    Dev.print('Colorized text fatal', level: DevLevel.fatal);
    Dev.print(
        '==========================Print Level Log End =====================',
        name: 'logLev');

    String text = 'Hello World!';
    Dev.print('Dev text print Not Debug: $text', isDebug: false, isLog: true);
    Dev.print('Dev text print2: $text', isLog: true);

    Dev.print('Dev text pirnt with the given level', level: DevLevel.error);

    Future<void>.delayed(const Duration(seconds: 1), () => allLevelLog());
    Future<void>.delayed(const Duration(seconds: 2), () => exeLog());
    Future<void>.delayed(const Duration(seconds: 3), () => catchErrorLog());
    Future<void>.delayed(const Duration(seconds: 4), () => debounceDemo());
    Future<void>.delayed(
        const Duration(seconds: 5), () => logLevelFilterDemo());
    Future<void>.delayed(const Duration(seconds: 6), () => tagFilterDemo());
  }

  void logLevelFilterDemo() {
    Dev.log(
        '==========================Log Level Filter Demo========================');

    Dev.log('📌 Demo: Two-level control system');
    Dev.log('   logLevel = controls CONSOLE OUTPUT');
    Dev.log('   exeLevel = controls CALLBACK EXECUTION');

    // Demo 1: Show all levels first (default)
    Dev.logLevel = DevLevel.verbose;
    Dev.log('--- Level 1: logLevel = verbose (show all in console) ---');
    Dev.logVerbose('🔍 Verbose: Detailed debug info - SHOWN IN CONSOLE');
    Dev.log('🔖 Normal: General log - SHOWN IN CONSOLE');
    Dev.logInfo('📬 Info: Informational message - SHOWN IN CONSOLE');
    Dev.logSuccess('🎉 Success: Operation completed - SHOWN IN CONSOLE');
    Dev.logWarn('🚧 Warning: Potential issue - SHOWN IN CONSOLE');
    Dev.logError('❌ Error: Something went wrong - SHOWN IN CONSOLE');
    Dev.logFatal('💣 Fatal: Critical error - SHOWN IN CONSOLE');

    // Demo 2: Filter verbose and normal from console
    Dev.logLevel = DevLevel.info;
    Dev.log('--- Level 2: logLevel = info (hide verbose & normal) ---');
    Dev.logVerbose('🔍 Verbose: HIDDEN from console');
    Dev.log('🔖 Normal: HIDDEN from console');
    Dev.logInfo('📬 Info: SHOWN IN CONSOLE');
    Dev.logWarn('🚧 Warning: SHOWN IN CONSOLE');
    Dev.logError('❌ Error: SHOWN IN CONSOLE');

    // Demo 3: Production mode - only show warnings and errors
    Dev.logLevel = DevLevel.warn;
    Dev.log('--- Level 3: logLevel = warning (production mode) ---');
    Dev.logVerbose('🔍 Verbose: HIDDEN');
    Dev.log('🔖 Normal: HIDDEN');
    Dev.logInfo('📬 Info: HIDDEN');
    Dev.logSuccess('🎉 Success: HIDDEN');
    Dev.logWarn('🚧 Warning: SHOWN (important!)');
    Dev.logError('❌ Error: SHOWN (critical!)');
    Dev.logFatal('💣 Fatal: SHOWN (urgent!)');

    // Demo 4: Critical production - only errors
    Dev.logLevel = DevLevel.error;
    Dev.log('--- Level 4: logLevel = error (critical production) ---');
    Dev.logWarn('🚧 Warning: HIDDEN from console');
    Dev.logError('❌ Error: SHOWN');
    Dev.logFatal('💣 Fatal: SHOWN');

    // Demo 5: Combine with exeLevel for dual control
    Dev.logLevel = DevLevel.info; // Console: info+
    Dev.exeLevel = DevLevel.warn; // Callback: warning+
    Dev.log('--- Level 5: Dual control demo ---');
    Dev.log('logLevel=info (console), exeLevel=warning (callback)');

    Dev.logInfo('📬 Info: Console ✓ shown, Callback ✗ not executed',
        execFinalFunc: true);
    Dev.logWarn('🚧 Warning: Console ✓ shown, Callback ✓ executed',
        execFinalFunc: true);
    Dev.logError('❌ Error: Console ✓ shown, Callback ✓ executed',
        execFinalFunc: true);

    // Reset to default
    Dev.logLevel = DevLevel.verbose;
    Dev.exeLevel = DevLevel.warn;
    Dev.log('--- Reset to default: logLevel=verbose, exeLevel=warning ---');

    Dev.log(
        '==========================Log Level Filter Demo End====================');
  }

  void debounceDemo() {
    Dev.log('==========================Debounce Demo========================');

    // Demo 1: Rapid button clicks - only first log should execute
    Dev.logInfo('Button clicked (1/5) - This should log',
        debounceMs: 1000, execFinalFunc: true);
    Dev.logInfo('Button clicked (2/5) - SKIPPED due to debounce',
        debounceMs: 1000, execFinalFunc: true);
    Dev.logInfo('Button clicked (3/5) - SKIPPED due to debounce',
        debounceMs: 1000, execFinalFunc: true);

    // Demo 1b: Using debounceKey with dynamic content
    for (int i = 1; i <= 3; i++) {
      Dev.logInfo('Click with timestamp ${DateTime.now()} (attempt $i)',
          debounceMs: 1000, debounceKey: 'dynamic_click', execFinalFunc: true);
    }

    // Demo 2: After debounce period, log should work again
    Future<void>.delayed(const Duration(milliseconds: 1100), () {
      Dev.logInfo('Button clicked after 1.1s - This should log again',
          debounceMs: 1000, execFinalFunc: true);
    });

    // Demo 3: Different messages have independent debounce
    Dev.logWarn('Warning A - This should log',
        debounceMs: 800, execFinalFunc: true);
    Dev.logWarn('Warning B - This should also log (different message)',
        debounceMs: 800, execFinalFunc: true);
    Dev.logWarn('Warning A - SKIPPED (same as first)',
        debounceMs: 800, execFinalFunc: true);

    // Demo 4: API request simulation with debounce (using debounceKey)
    for (int i = 0; i < 5; i++) {
      Future<void>.delayed(Duration(milliseconds: i * 100), () {
        Dev.exe('API Request /users - Call ${i + 1} at ${DateTime.now()}',
            level: DevLevel.success, debounceMs: 500, debounceKey: 'api_users');
      });
    }

    // Demo 5: Error logging with debounce to prevent spam
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      for (int i = 0; i < 3; i++) {
        Dev.exeError('Network timeout error occurred',
            debounceMs: 2000, isMultConsole: true);
      }
    });

    // Demo 6: Scroll position simulation with debounceKey
    Future<void>.delayed(const Duration(milliseconds: 2000), () {
      for (double offset = 0; offset < 500; offset += 50) {
        Dev.logWarn('Scroll position: ${offset}px',
            debounceMs: 300,
            debounceKey: 'scroll_position',
            execFinalFunc: true);
      }
    });

    Dev.log('==========================Debounce Demo End====================');
  }

  void catchErrorLog() {
    try {
      final List a = [];
      final x = a[9] + 3;
      Dev.print(x);
    } catch (e) {
      /// V 1.2.8 special error formatter
      Dev.exeFatal('fatal error: $e', error: e);
      Dev.print(e, error: e, level: DevLevel.error);
      Dev.logError('$e', error: e);
      Dev.exeError('$e', error: e, colorInt: 91);
    }

    final List a = [];
    final x = a[9] + 3;
    Dev.print(x);
  }

  void exeLog() {
    Dev.exe('!!!!1.Exec Colorized text Success', level: DevLevel.success);
    Dev.exe('!!!!1.Exec Colorized text');
    Dev.exe('!!!!2.Exec Colorized text Warning', level: DevLevel.warn);
    Dev.exe('!!!!3.Exec Colorized text Warning ColorInt',
        level: DevLevel.warn, colorInt: 101);
    Dev.exe('!!!!4.Exec Colorized text Success Without logging',
        level: DevLevel.success, isLog: false);
    Dev.exe('!!!!5.Exec Colorized text Error With debug print',
        level: DevLevel.error, isMultConsole: true);
    Dev.exe('!!!!6.Exec Colorized text Info With unlti print',
        level: DevLevel.info, isMultConsole: true, isDebug: false);
    Dev.exe('!!!!7.Exec Colorized text Success Without printing',
        level: DevLevel.success, isMultConsole: true, isLog: false);

    Dev.exe('==========================Exe Level Log========================',
        name: 'logLev');
    Dev.exe("Exec Normal");
    Dev.exeVerbose("Exec Verbose (detailed debug)");
    Dev.exeInfo("Exec Info");
    Dev.exeSuccess("Exec Success");
    Dev.exeWarn("Exec Warning");
    Dev.exeError("Exec Error");
    Dev.exeFatal("Exec Fatal");
    Dev.exe('==========================Exe Level Log End =====================',
        name: 'logLev');
  }

  void allLevelLog() {
    Dev.log('==========================Level Log========================',
        name: 'logLev', execFinalFunc: true);
    Dev.logVerbose('Colorized text Verbose execFinalFunc: true',
        execFinalFunc: true);
    Dev.log('Colorized text log execFinalFunc: true',
        fileLocation: 'main.dart:90xx', execFinalFunc: true);
    Dev.logInfo('Colorized text Info execFinalFunc: true', execFinalFunc: true);
    Dev.logSuccess('Colorized text Success execFinalFunc: true',
        execFinalFunc: true);
    Dev.logWarn('Colorized text Warning execFinalFunc: true',
        execFinalFunc: true);
    Dev.logError('Colorized text Error execFinalFunc: true',
        execFinalFunc: true);
    Dev.logFatal('Colorized text fatal execFinalFunc: true',
        execFinalFunc: true);
    Dev.log('========================Level Log End ======================',
        isLog: true, execFinalFunc: true);

    String text = 'Hello World!';
    Dev.print('Dev text print Not Debug execFinalFunc: $text',
        isDebug: false, isLog: true, execFinalFunc: true);
    Dev.print('Dev text print2 execFinalFunc: $text',
        isLog: true, execFinalFunc: true);

    Dev.print('Dev text pirnt with the given level exec!!!',
        level: DevLevel.success, isLog: false, execFinalFunc: true);

    Dev.log('1.log success level', level: DevLevel.success);
    Dev.logSuccess('2.log success level');
    Dev.log('1.log success level and exec',
        level: DevLevel.success, execFinalFunc: true);
    Dev.exe('2.log success level and exec', level: DevLevel.success);
    Dev.exeSuccess('3.log success level and exec');
  }

  void tagFilterDemo() {
    Dev.log(
        '==========================Tag Filter Demo========================');

    Dev.log('📌 Demo: Tag-based log filtering for modular development');
    Dev.log('   Dev.isFilterByTags = controls whether to filter by tags');
    Dev.log(
        '   Dev.tags = defines which tags to display (when filtering enabled)');
    Dev.log(
        '   Tags can be auto-detected from file path or manually specified');

    // Demo 1: Default behavior - show all logs with tag information
    Dev.isFilterByTags = false;
    Dev.tags = null;
    Dev.log('--- Demo 1: Default (isFilterByTags = false, show all) ---');
    Dev.logInfo('📦 Log from auth module', tag: 'auth');
    Dev.logInfo('🌐 Log from network module', tag: 'network');
    Dev.logInfo('💾 Log from database module', tag: 'database');
    Dev.logInfo('🎨 Log from ui module', tag: 'ui');
    Dev.logInfo('📝 Log without tag');

    // Demo 2: Show tag info without filtering
    Dev.isFilterByTags = false;
    Dev.tags = {'auth', 'network'}; // Define tags but don't filter
    Dev.log(
        '--- Demo 2: Tag info shown, no filtering (isFilterByTags = false) ---');
    Dev.logInfo('📦 Auth: User info (shown with [tag:auth])', tag: 'auth');
    Dev.logInfo('🌐 Network: API call (shown with [tag:network])',
        tag: 'network');
    Dev.logInfo('💾 Database: Query (shown with [tag:database])',
        tag: 'database');
    Dev.logInfo('📝 Untagged log (shown without tag)');

    // Demo 3: Enable filtering - single tag
    Dev.isFilterByTags = true;
    Dev.tags = {'auth'};
    Dev.log(
        '--- Demo 3: Filter single tag (isFilterByTags = true, tags = {\'auth\'}) ---');
    Dev.logSuccess('✅ Auth: User logged in successfully', tag: 'auth');
    Dev.logInfo('🌐 Network: API call (HIDDEN)', tag: 'network');
    Dev.logInfo('💾 Database: Query executed (HIDDEN)', tag: 'database');
    Dev.logWarn('⚠️ Auth: Session about to expire', tag: 'auth');
    Dev.logInfo('📝 Untagged log (HIDDEN)');

    // Demo 4: Enable filtering - multiple tags
    Dev.isFilterByTags = true;
    Dev.tags = {'auth', 'network'};
    Dev.log('--- Demo 4: Filter multiple tags (show "auth" and "network") ---');
    Dev.logSuccess('✅ Auth: Login successful', tag: 'auth');
    Dev.logInfo('🌐 Network: Fetching user data', tag: 'network');
    Dev.logInfo('💾 Database: Saving to cache (HIDDEN)', tag: 'database');
    Dev.logSuccess('🌐 Network: API response received', tag: 'network');
    Dev.logError('❌ Auth: Invalid credentials', tag: 'auth');

    // Demo 5: Practical example - debugging specific feature
    Dev.isFilterByTags = true;
    Dev.tags = {'payment'};
    Dev.log('--- Demo 5: Debug payment feature only ---');
    Dev.logInfo('💳 Payment: Initiating transaction', tag: 'payment');
    Dev.logInfo('🌐 Network: Contacting payment gateway (HIDDEN)',
        tag: 'network');
    Dev.logSuccess('💳 Payment: Transaction verified', tag: 'payment');
    Dev.logInfo('💾 Database: Saving receipt (HIDDEN)', tag: 'database');
    Dev.logSuccess('💳 Payment: Receipt generated', tag: 'payment');

    // Demo 6: Tag filtering with different log levels
    Dev.isFilterByTags = true;
    Dev.tags = {'security'};
    Dev.log('--- Demo 6: Security logs with different levels ---');
    Dev.logVerbose('🔒 Security: Checking permissions', tag: 'security');
    Dev.logInfo('🔒 Security: User authenticated', tag: 'security');
    Dev.logWarn('⚠️ Security: Suspicious activity detected', tag: 'security');
    Dev.logError('❌ Security: Unauthorized access attempt', tag: 'security');
    Dev.logFatal('💣 Security: Critical breach detected', tag: 'security');
    Dev.logInfo('📱 UI: Screen loaded (HIDDEN)', tag: 'ui');

    // Demo 7: Auto-detection from file path simulation
    Dev.isFilterByTags = true;
    Dev.tags = {'features', 'services'};
    Dev.log('--- Demo 7: Auto-detection from file path ---');
    Dev.log(
        'Imagine these logs come from: lib/features/user/user_service.dart');
    Dev.log(
        'The tag "features" would be auto-detected and shown if in Dev.tags');
    Dev.logInfo('👤 Processing user data', tag: 'features');
    Dev.logInfo('🔧 Service initialized', tag: 'services');
    Dev.logInfo('🎨 Rendering UI (HIDDEN)', tag: 'ui');

    // Demo 8: Empty tag set - hides everything when filtering enabled
    Dev.isFilterByTags = true;
    Dev.tags = {};
    Dev.log('--- Demo 8: Empty tag set (tags = {}, hide all with tags) ---');
    Dev.logInfo('All these logs have tags, so they are HIDDEN', tag: 'hidden');
    Dev.logInfo('This one too', tag: 'hidden');
    Dev.logInfo('And this one', tag: 'hidden');

    // Demo 9: Combining with execFinalFunc
    Dev.isFilterByTags = true;
    Dev.tags = {'critical'};
    Dev.log('--- Demo 9: Tag filter + execFinalFunc (still executes) ---');
    Dev.log('Tag filtering only affects console output');
    Dev.log('execFinalFunc will execute regardless of tag matching');
    Dev.exeError('💥 Critical error logged to remote server',
        tag: 'critical'); // Shown + executed
    Dev.exeWarn('⚠️ Normal warning (HIDDEN in console but callback executed)',
        tag: 'normal'); // Hidden but callback still runs
    Dev.exeError('❌ Another critical error',
        tag: 'critical'); // Shown + executed

    // Demo 10: Practical use case - development environment
    Dev.isFilterByTags = true;
    Dev.tags = {'debug', 'test'};
    Dev.log('--- Demo 10: Development environment debugging ---');
    Dev.logVerbose('🔍 Debug: Variable state = loading', tag: 'debug');
    Dev.logInfo('🧪 Test: Running integration test', tag: 'test');
    Dev.logInfo('📊 Analytics: Event tracked (HIDDEN)', tag: 'analytics');
    Dev.logVerbose('🔍 Debug: Response time = 124ms', tag: 'debug');
    Dev.logSuccess('✅ Test: All tests passed', tag: 'test');

    // Demo 11: Real-world scenario - monitoring specific module
    Dev.isFilterByTags = true;
    Dev.tags = {'api', 'cache'};
    Dev.log('--- Demo 11: Monitor API and cache performance ---');
    Dev.logInfo('🌐 API: GET /users/123', tag: 'api');
    Dev.logInfo('💾 Cache: Checking cache for key:user:123', tag: 'cache');
    Dev.logInfo('💾 Cache: Cache miss', tag: 'cache');
    Dev.logInfo('🌐 API: Response received (200ms)', tag: 'api');
    Dev.logInfo('💾 Cache: Storing result with TTL 300s', tag: 'cache');
    Dev.logInfo('🎨 UI: Updating user profile (HIDDEN)', tag: 'ui');

    // Reset to default (no filtering)
    Dev.isFilterByTags = false;
    Dev.tags = null;
    Dev.log('--- Reset: Tag filtering disabled (isFilterByTags = false) ---');
    Dev.logInfo('✅ All logs now visible again', tag: 'any');
    Dev.logInfo('✅ Regardless of tag', tag: 'tag');
    Dev.logInfo('✅ Or no tag at all');

    Dev.log(
        '==========================Tag Filter Demo End====================');
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.label),
            tooltip: 'Tag Demo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TagDemoPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
                child: UITextView(
              key: textViewKey,
              initialText: "Logs:",
              textStyle: const TextStyle(fontSize: 16.0, color: Colors.black),
            )),
            const SizedBox(height: 20),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _testDebounce,
              icon: const Icon(Icons.timer),
              label: Text('Test Debounce (Clicks: $_debounceClickCount)'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            const Text(
              'Try clicking rapidly! Logs debounced for 10 seconds.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
