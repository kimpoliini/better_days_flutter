import 'dart:math';

import 'package:better_days_flutter/main.dart';
import 'package:better_days_flutter/widgets/history_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    var sortedEntries = state.historyEntries;
    sortedEntries.sort((a, b) => b.date.compareTo(a.date));

    final List<Widget> testHistoryEntries = <Widget>[
      for (var entry in sortedEntries) HistoryCard(entry: entry)
    ];

    return ListView(
      children: testHistoryEntries,
    );
  }
}
