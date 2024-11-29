import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'hive_model.dart';

class HiveService {
  static Future<void> init() async {
    // Initialize Hive.
    final appDocDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocDir.path);

    // Register the HiveModel adapter.
    Hive.registerAdapter(HiveModelAdapter());
  }
}