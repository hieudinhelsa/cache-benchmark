import 'package:cache_benchmark/hive_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'hive_service.dart';
import 'dart:io';
import 'drift_database.dart';
import 'isar_service.dart';
import 'isar_model.dart';
import 'package:path/path.dart' as p;
import 'package:isar/isar.dart';

final driftDatabase = AppDatabase();
final isarService = IsarService(); // Initialize the IsarService.

final dataSize = 1000;

Future<void> insertHiveData() async {
  final stopwatch = Stopwatch()..start();
  await Future.wait(
    List.generate(dataSize, (i) => Hive.box('my_box').put(i, HiveModel(i, 'Value $i')))
  );
  stopwatch.stop();
  print('Insert Hive data took ${stopwatch.elapsedMilliseconds} ms');
}


Future<void> getHiveData() async {
  final stopwatch = Stopwatch()..start();
  final result = Hive.box('my_box').values;
  stopwatch.stop();
  print('Hive data length: ${result.length}');
  print('Get Hive data took ${stopwatch.elapsedMilliseconds} ms');
}

Future<void> updateHiveData() async {
  final stopwatch = Stopwatch()..start();
  for (int i = 0; i < 100000; i++) {
    await Hive.box('my_box').put(i, HiveModel(i, 'Updated Value $i'));
  }
  stopwatch.stop();
  print('Update Hive data took ${stopwatch.elapsedMilliseconds} ms');
}

Future<void> deleteHiveData() async {
  final stopwatch = Stopwatch()..start();
  
  final box = Hive.box('my_box');
  await box.clear();
  
  stopwatch.stop();
  print('Delete Hive data took ${stopwatch.elapsedMilliseconds} ms');
}

Future<void> insertDriftData() async {
  final stopwatch = Stopwatch()..start();
  for (int i = 0; i < dataSize; i++) {
    await driftDatabase.into(driftDatabase.users).insert(
      UsersCompanion.insert(
        name: 'User $i',
      ),
    );
  }
  stopwatch.stop();
  print('Insert Drift data took ${stopwatch.elapsedMilliseconds} ms');
}

Future<void> getDriftData() async {
  final stopwatch = Stopwatch()..start();
  final users = await driftDatabase.select(driftDatabase.users).get();
  stopwatch.stop();
  print('Drift data length: ${users.length}');
  print('Get Drift data took ${stopwatch.elapsedMilliseconds} ms');
}

Future<void> getDriftSize() async {
  // Path to the database file
  final dir = await getApplicationDocumentsDirectory();
  final dbPath = p.join(dir.path, 'drift_database.sqlite');
  final file = File(dbPath);

  // Check if the file exists
  if (await file.exists()) {
    // Get the size of the database file in bytes
    final sizeInBytes = await file.length();
    final sizeInMB = sizeInBytes / (1024 * 1024);
    print('Drift database size: ${sizeInMB.toStringAsFixed(2)} MB');
  } else {
    print('Database file does not exist.');
  }
}

Future<void> deleteDriftData() async {
  final stopwatch = Stopwatch()..start();
  await (driftDatabase.delete(driftDatabase.users)).go();
  stopwatch.stop();
  print('Delete Drift data took ${stopwatch.elapsedMilliseconds} ms');
}


Future<void> getHiveSize() async {
  final box = Hive.box('my_box');

  // Method 2: Get the file size in bytes
  final path = box.path;
  if (path != null) {
    final file = File(path);
    final sizeInBytes = await file.length();
    final sizeInMB = sizeInBytes / (1024 * 1024);
    print('Hive database size: ${sizeInMB.toStringAsFixed(2)} MB');
  }
}

Future<void> insertIsarData() async {
  final stopwatch = Stopwatch()..start();
 
  final users = List.generate(dataSize, (i) {
    final model = UserModel();
    model.name = 'User $i';  // Create unique name for each user
    return model;
  });

  final db = await isarService.database;
  
  await db.writeTxn(() async {
    await db.userModels.putAll(users);
  });
  
  stopwatch.stop();
  print('Insert Isar data took ${stopwatch.elapsedMilliseconds} ms');
}

Future<void> readIsarData() async {
  final stopwatch = Stopwatch()..start();
  final db = await isarService.database;
  final users = await db.userModels.where().findAll();
  stopwatch.stop();
  print('Isar data length: ${users.length}');
  print('Get Isar data took ${stopwatch.elapsedMilliseconds} ms');
}

Future<void> deleteIsarData() async {
  final stopwatch = Stopwatch()..start();
  final db = await isarService.database;
  await db.writeTxn(() async {
    await db.userModels.clear(); // Delete all users
  });
  stopwatch.stop();
  print('Delete Isar data took ${stopwatch.elapsedMilliseconds} ms');
}

Future<void> getIsarSize() async {
  final db = await isarService.database;
  // Get instance size from Isar directly
  final instanceSize = await db.getSize();
  final instanceSizeInMB = instanceSize / (1024 * 1024);
  print('Isar database size: ${instanceSizeInMB.toStringAsFixed(2)} MB');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const MyApp());
  print("=========Starting benchmark...=========");
  print("Data size: $dataSize");
  print("");

  print("=========Starting benchmark Hive...=========");
  await Hive.openBox('my_box');
  await insertHiveData();
  await getHiveData();
  await getHiveSize();
  await deleteHiveData();
  print("=========Ending benchmark Hive...=========");
  print("");

  print("=========Starting benchmark Drift...=========");
  await insertDriftData();
  await getDriftData();
  await getDriftSize();
  await deleteDriftData();
  print("=========Ending benchmark Drift...=========");
  print("");

  print("=========Starting benchmark Isar...=========");  
  await insertIsarData();
  await readIsarData();
  await getIsarSize();
  await deleteIsarData();
  print("=========Ending benchmark Isar...=========");
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
        // the application has a purple toolbar. Then, without quitting the app,
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

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
