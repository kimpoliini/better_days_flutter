import 'package:isar/isar.dart';

part 'history_item.g.dart';

@collection
class HistoryItem {
  Id id = Isar.autoIncrement;

  DateTime? date;
  String? description;
  double? score;
  List<HourScore>? scores;
}

@embedded
class HourScore {
  int? hour;
  double? score;
}
