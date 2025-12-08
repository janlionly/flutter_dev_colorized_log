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
        colorInt: _counter, execFinalFunc: true, level: DevLevel.logWar);
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

    Dev.exeLevel = DevLevel.logWar;
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

    Dev.logWarning('Messy whitespace cleaned up:\n$messyExample');

    // Disable newline replacement to show difference
    Dev.isReplaceNewline = false;
    Dev.logWarning(
        'Multi-line warning without replacement:\n$multiLineExample');

    // Re-enable with custom replacement character
    Dev.isReplaceNewline = true;
    Dev.newlineReplacement = ' >> ';
    Dev.logWarning(
        'Multi-line warning with custom replacement:\n$multiLineExample');

    // Reset to default
    Dev.newlineReplacement = ' | ';

    /// V 1.2.8 colorize multi lines
    Dev.log('===================== Multi lines log =====================');
    const multiLines = '''
      🔴 [ERROR] UniqueID: 1
      🕒 Timestamp: 2
      📛 ErrorType: 3
      💥 ErrorMessage: 4
      📚 StackTrace: 5
    ''';
    Dev.logError(multiLines);
    Dev.isReplaceNewline = false;
    Dev.logError(multiLines);

    Dev.log('==========================All Color Log========================');
    printCustomText();

    Dev.log('==========================Log Level Log========================',
        name: 'logLev');
    Dev.log('Colorized text log', fileLocation: 'main.dart:90xx---------');
    Dev.logInfo('Colorized text Info');
    Dev.logSuccess('Colorized text Success');
    Dev.logWarning('Colorized text Warning');
    Dev.logError('Colorized text Error');
    Dev.logBlink('Colorized text blink');
    Dev.log(
        '==========================Log Level Log End ======================',
        isLog: true);

    Dev.print(
        '==========================Print Level Log========================',
        name: 'logLev');
    Dev.print('Colorized text log', level: DevLevel.logNor);
    Dev.print('Colorized text Info', level: DevLevel.logInf);
    Dev.print('Colorized text Success', level: DevLevel.logSuc);
    Dev.print('Colorized text Warning', level: DevLevel.logWar);
    Dev.print('Colorized text Error', level: DevLevel.logErr);
    Dev.print('Colorized text blink', level: DevLevel.logBlk);
    Dev.print(
        '==========================Print Level Log End =====================',
        name: 'logLev');

    String text = 'Hello World!';
    Dev.print('Dev text print Not Debug: $text', isDebug: false, isLog: true);
    Dev.print('Dev text print2: $text', isLog: true);

    Dev.print('Dev text pirnt with the given level', level: DevLevel.logErr);

    Future<void>.delayed(const Duration(seconds: 1), () => allLevelLog());
    Future<void>.delayed(const Duration(seconds: 2), () => exeLog());
    Future<void>.delayed(const Duration(seconds: 3), () => catchErrorLog());
  }

  void catchErrorLog() {
    try {
      final List a = [];
      final x = a[9] + 3;
      Dev.print(x);
    } catch (e) {
      /// V 1.2.8 special error formatter
      Dev.print(e, error: e, level: DevLevel.logErr);
      Dev.logError('$e', error: e);
      Dev.exeError('$e', error: e, colorInt: 91);
    }

    final List a = [];
    final x = a[9] + 3;
    Dev.print(x);
  }

  void exeLog() {
    Dev.exe('!!!!1.Exec Colorized text Success', level: DevLevel.logSuc);
    Dev.exe('!!!!1.Exec Colorized text');
    Dev.exe('!!!!2.Exec Colorized text Warning', level: DevLevel.logWar);
    Dev.exe('!!!!3.Exec Colorized text Warning ColorInt',
        level: DevLevel.logWar, colorInt: 101);
    Dev.exe('!!!!4.Exec Colorized text Success Without logging',
        level: DevLevel.logSuc, isLog: false);
    Dev.exe('!!!!5.Exec Colorized text Error With debug print',
        level: DevLevel.logErr, isMultConsole: true);
    Dev.exe('!!!!6.Exec Colorized text Info With unlti print',
        level: DevLevel.logInf, isMultConsole: true, isDebug: false);
    Dev.exe('!!!!7.Exec Colorized text Success Without printing',
        level: DevLevel.logSuc, isMultConsole: true, isLog: false);

    Dev.exe('==========================Exe Level Log========================',
        name: 'logLev');
    Dev.exe("Exec Normal");
    Dev.exeInfo("Exec Info");
    Dev.exeSuccess("Exec Success");
    Dev.exeWarning("Exec Warning");
    Dev.exeError("Exec Error");
    Dev.exeBlink("Exec Blink");
    Dev.exe('==========================Exe Level Log End =====================',
        name: 'logLev');
  }

  void allLevelLog() {
    Dev.log('==========================Level Log========================',
        name: 'logLev', execFinalFunc: true);
    Dev.log('Colorized text log execFinalFunc: true',
        fileLocation: 'main.dart:90xx', execFinalFunc: true);
    Dev.logInfo('Colorized text Info execFinalFunc: true', execFinalFunc: true);
    Dev.logSuccess('Colorized text Success execFinalFunc: true',
        execFinalFunc: true);
    Dev.logWarning('Colorized text Warning execFinalFunc: true',
        execFinalFunc: true);
    Dev.logError('Colorized text Error execFinalFunc: true',
        execFinalFunc: true);
    Dev.logBlink('Colorized text blink execFinalFunc: true',
        execFinalFunc: true);
    Dev.log('========================Level Log End ======================',
        isLog: true, execFinalFunc: true);

    String text = 'Hello World!';
    Dev.print('Dev text print Not Debug execFinalFunc: $text',
        isDebug: false, isLog: true, execFinalFunc: true);
    Dev.print('Dev text print2 execFinalFunc: $text',
        isLog: true, execFinalFunc: true);

    Dev.print('Dev text pirnt with the given level exec!!!',
        level: DevLevel.logSuc, isLog: false, execFinalFunc: true);

    Dev.log('1.log success level', level: DevLevel.logSuc);
    Dev.logSuccess('2.log success level');
    Dev.log('1.log success level and exec',
        level: DevLevel.logSuc, execFinalFunc: true);
    Dev.exe('2.log success level and exec', level: DevLevel.logSuc);
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
