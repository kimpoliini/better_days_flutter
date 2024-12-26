import 'package:isar/isar.dart';

part 'history_item.g.dart';

@collection
class HistoryItem {
  Id id = Isar.autoIncrement;

  @Index()
  DateTime? date;
  String? description;
  bool isDescriptionHidden = false;
  bool isBookmarked = false;
  double? score;
  List<HourScore>? scores;
}

@embedded
class HourScore {
  int? hour;
  double? score;
}
