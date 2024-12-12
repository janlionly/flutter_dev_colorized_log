import 'package:flutter/material.dart';
import 'package:dev_colorized_log/dev_colorized_log.dart';

void main() {
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
  _UITextViewState createState() => _UITextViewState();
}

class _UITextViewState extends State<UITextView> {
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
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Text(
          _text,
          style: widget.textStyle ?? TextStyle(fontSize: 16.0),
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
  final GlobalKey<_UITextViewState> textViewKey = GlobalKey<_UITextViewState>();

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
    Dev.log('Colorized text custom with colorInt: $_counter', colorInt: _counter, execFinalFunc: true);
  }

  void printCustomText() {
    for (int i = 0; i < 108; i++) {
      Dev.log('Colorized text custom with colorInt: $i', colorInt: i);
    }
  }

  @override
  void initState() {
    super.initState();
    Dev.enable = true;
    Dev.isDebugPrint = true;
    Dev.isLogFileLocation = true;
    Dev.defaultColorInt = 0;
    Dev.customFinalFunc = (msg) {
      textViewKey.currentState?.appendText(msg);
    };


    Dev.log('==========================All Color Log========================');
    printCustomText();

    Dev.log('==========================Level Log========================', name: 'logLev');
    Dev.log('Colorized text log', fileLocation: 'main.dart:90xx');
    Dev.logInfo('Colorized text Info');
    Dev.logSuccess('Colorized text Success');
    Dev.logWarning('Colorized text Warning');
    Dev.logError('Colorized text Error');
    Dev.logBlink('Colorized text blink', isSlow: true);
    Dev.log('========================Level Log End ======================', isLog: true);

    String text = 'Hello World!';
    Dev.print('Dev text print Not Debug: $text', isDebug: false, isLog: true);
    Dev.print('Dev text print2: $text', isLog: true);

    Dev.print('Dev text pirnt with the given level', level: DevLevel.logErr);

    try {
      final List a = [];
      final x = a[9] + 3;
      Dev.print(x);
    }
    catch(e) {
      Dev.print(e);
    }

    Future<void>.delayed(const Duration(seconds: 1), ()=> allLevelLog());

    Future<void>.delayed(const Duration(seconds: 2), ()=> exeLog());
  }

  void exeLog() {
    Dev.exe('!!!!1.Exec Colorized text');
    Dev.exe('!!!!2.Exec Colorized text Warning', level: DevLevel.logWar);
    Dev.exe('!!!!3.Exec Colorized text Warning ColorInt', level: DevLevel.logWar, colorInt: 101);
    Dev.exe('!!!!4.Exec Colorized text Success Without logging', level: DevLevel.logSuc, isLog: false);
    Dev.exe('!!!!5.Exec Colorized text Error With debug print', level: DevLevel.logErr, isMultConsole: true);
    Dev.exe('!!!!6.Exec Colorized text Info With unlti print', level: DevLevel.logInf, isMultConsole: true, isDebug: false);
    Dev.exe('!!!!7.Exec Colorized text Success Without printing', level: DevLevel.logSuc, isMultConsole: true, isLog: false);
  }

  void allLevelLog() {
    Dev.log('==========================Level Log========================', name: 'logLev', execFinalFunc: true);
    Dev.log('Colorized text log', fileLocation: 'main.dart:90xx', execFinalFunc: true);
    Dev.logInfo('Colorized text Info', execFinalFunc: true);
    Dev.logSuccess('Colorized text Success', execFinalFunc: true);
    Dev.logWarning('Colorized text Warning', execFinalFunc: true);
    Dev.logError('Colorized text Error', execFinalFunc: true);
    Dev.logBlink('Colorized text blink', isSlow: true, execFinalFunc: true);
    Dev.log('========================Level Log End ======================', isLog: true, execFinalFunc: true);

    String text = 'Hello World!';
    Dev.print('Dev text print Not Debug execFinalFunc: $text', isDebug: false, isLog: true, execFinalFunc: true);
    Dev.print('Dev text print2 execFinalFunc: $text', isLog: true, execFinalFunc: true);

    Dev.print('Dev text pirnt with the given level exec!!!', level: DevLevel.logSuc, isLog: false, execFinalFunc: true);
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
                initialText: "Log Infos",
                textStyle: TextStyle(fontSize: 16.0, color: Colors.black),
              )
            ),
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
