import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
// Include generated code
part 'drift_database.g.dart';

// Define a Drift table
class Users extends Table {
  IntColumn get id => integer().autoIncrement()(); // Primary key
  TextColumn get name => text().withLength(min: 1, max: 50)();
}

// Create a database class
@DriftDatabase(tables: [Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1; // Increment this if you change the schema
}

// Open connection to the database
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'drift_database.sqlite'));
    return NativeDatabase(file);
  });
}