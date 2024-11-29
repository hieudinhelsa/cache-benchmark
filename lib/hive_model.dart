import 'package:hive/hive.dart';

part 'hive_model.g.dart';


@HiveType(typeId: 0)
class HiveModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String value;

  HiveModel(this.id, this.value);
}