import 'dart:math';

import 'package:better_days_flutter/main.dart';
import 'package:better_days_flutter/widgets/history_card.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    var sortedEntries = state.historyEntries;
    sortedEntries.sort((a, b) => b.date.compareTo(a.date));

    final List<Widget> testHistoryEntries = <Widget>[
      for (var entry in sortedEntries)
        Dismissible(
            onDismissed: (direction) {
              state.removeEntry(entry);
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      "Entry at ${DateFormat.yMMMd().format(entry.date)} removed")));
            },
            key: Key(entry.date.toString()),
            child: HistoryCard(entry: entry))
    ];

    return ListView(
      dragStartBehavior: DragStartBehavior.start,
      children: testHistoryEntries,
    );
  }
}
