import 'package:better_days_flutter/schemas/history_item.dart';

class HistoryEntry {
  DateTime date;
  String? description;
  bool isDescriptionHidden;
  bool isBookmarked;
  double? score;
  List<HourScore>? scores;

  HistoryEntry(
      {required this.date,
      this.description,
      this.isDescriptionHidden = false,
      this.isBookmarked = false,
      this.score,
      this.scores});
}
