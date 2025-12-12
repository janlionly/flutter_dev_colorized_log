import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:dev_colorized_log/dev_colorized_log.dart';

void main() {
  Dev.enable = true;
  Dev.isMultConsoleLog = true;
  Dev.isDebugPrint = true;
  Dev.isLogFileLocation = true;
  Dev.isExeDiffColor = false;
  Dev.prefixName = 'MyApp-';

  FlutterError.onError = (FlutterErrorDetails details) {
    Dev.logError('dev_colorized_log:',
        error: details.exception, stackTrace: details.stack);
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    Dev.logError('dev_colorized_log:', error: error, stackTrace: stack);
    return true;
  };
  runApp(const MyApp());
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
  late String _text;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _text = widget.initialText;
  }

  void appendText(String newText) {
    setState(() {
      _text += "\n$newText";
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
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
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Text(
          _text,
          style: widget.textStyle ?? const TextStyle(fontSize: 16.0),
        ),
      ),
    );
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

    /// V 2.0.4 newline replacement for better search visibility
    Dev.isReplaceNewline = true; // default is false
    Dev.newlineReplacement = ' | '; // default is ' | '

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
    Dev.isReplaceNewline = false;
    Dev.logWarn('Multi-line warning without replacement:\n$multiLineExample');

    // Re-enable with custom replacement character
    Dev.isReplaceNewline = true;
    Dev.newlineReplacement = ' >> ';
    Dev.logWarn(
        'Multi-line warning with custom replacement:\n$multiLineExample');

    // Reset to default
    Dev.newlineReplacement = ' | ';

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
    Dev.isReplaceNewline = false;
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
