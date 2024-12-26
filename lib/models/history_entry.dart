class HistoryEntry {
  DateTime date;
  String? description;
  bool isDescriptionHidden = false;
  double? score;

  HistoryEntry(
      {required this.date,
      this.description,
      required this.isDescriptionHidden,
      this.score});
}
