import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

late Logger logger;

Future<File> getLogFile() async {
  final appDocDir = await getApplicationDocumentsDirectory();

  final logsDir = Directory(appDocDir.path);
  if (!logsDir.existsSync()) logsDir.createSync();
  return File(path.join(logsDir.path, 'app_log.txt'));
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    final logFile = await getLogFile();
    try {
      final time = DateTime.now().toString();
      logFile.writeAsStringSync(
        '$time - Application starting...   ${logFile.path} ',
      );
    } catch (e) {
      print('Failed to write initial log: $e');
    }
    logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: FileOutput(file: logFile),
    );

    FlutterError.onError = (FlutterErrorDetails details) {
      try {
        final timestamp = DateTime.now().toString();
        logFile.writeAsStringSync(
          '$timestamp -   ${logFile.uri} Flutter Error:\n${details.exception}\n${details.stack}\n',
          mode: FileMode.append,
        );
      } catch (e) {
        print('Failed to log Flutter error: $e');
      }
    };

    runApp(const MyApp());
  } catch (e, stackTrace) {
    try {
      final logFile = await getLogFile();
      final timestamp = DateTime.now().toString();
      logFile.writeAsStringSync(
        '$timestamp     ${logFile.uri} \nFATAL ERROR:\n$e\n$stackTrace\n\n',
        mode: FileMode.append,
      );
    } catch (fileError) {
      print('Failed to write to log file: $fileError');
      print('Original error: $e');
      print('Stack trace: $stackTrace');
    }
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    logger.d('Building MyApp widget');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Demo App without package'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    logger.d('MyHomePage initialized');
  }

  @override
  Widget build(BuildContext context) {
    logger.d('Building MyHomePage widget');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Hello', textScaleFactor: 3),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TestPage(),
              ));
        },
      ),
    );
  }
}

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    logger.d('Building TestPage widget');
    return Scaffold(
      appBar: AppBar(title: const Text("Test Page")),
    );
  }
}
