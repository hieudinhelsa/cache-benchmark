import 'package:isar/isar.dart';

part 'isar_model.g.dart';

@collection
class UserModel {
  Id id = Isar.autoIncrement; // you need to initialize the Id field
  
  @Index() // optional: add this if you want to query by name
  late String name;
}