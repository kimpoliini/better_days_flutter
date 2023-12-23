import 'package:better_days_flutter/widgets/HistoryCard.dart';
import 'package:flutter/material.dart';

class History extends StatelessWidget {
  const History({super.key});

  static final List<Widget> _testHistoryEntries = <Widget>[
    HistoryCard(date: DateTime(2017, 9, 7)),
    HistoryCard(
      date: DateTime(2017, 9, 7),
      description: "hej",
    ),
    HistoryCard(date: DateTime(2017, 9, 7)),
    HistoryCard(date: DateTime(2017, 9, 7)),
    HistoryCard(date: DateTime(2017, 9, 7)),
    HistoryCard(date: DateTime(2017, 9, 7)),
  ];

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [],
    );
  }
}
