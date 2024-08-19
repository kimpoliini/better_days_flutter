import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  String? firstName;
  String? lastName;

  DateTime? birthday;
  DateTime? joined;

  //Additional
  String? motto;
  String? email;
  String? phone;
  String? address;
  List<String>? medication;
  List<String>? links;
}
