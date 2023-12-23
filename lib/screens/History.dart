import 'package:better_days_flutter/models/history_entry.dart';
import 'package:better_days_flutter/widgets/HistoryCard.dart';
import 'package:flutter/material.dart';

class History extends StatelessWidget {
  const History({super.key});

  static final List<Widget> _testHistoryEntries = <Widget>[
    for (int i = 0; i < 20; i++)
      HistoryCard(entry: HistoryEntry(date: DateTime(2017, 9, 7)))
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _testHistoryEntries,
    );
  }
}
