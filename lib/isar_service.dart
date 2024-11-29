import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'isar_model.dart';

class IsarService {
  late Future<Isar> database;

  IsarService() {
    database = _initDatabase();
  }

  Future<Isar> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open(
      [UserModelSchema], // Register your collection schemas here.
      directory: dir.path,
    );
  }
}