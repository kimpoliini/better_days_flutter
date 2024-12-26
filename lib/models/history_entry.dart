class HistoryEntry {
  DateTime date;
  String? description;
  bool isDescriptionHidden;
  bool isBookmarked;
  double? score;

  HistoryEntry(
      {required this.date,
      this.description,
      this.isDescriptionHidden = false,
      this.isBookmarked = false,
      this.score});
}
