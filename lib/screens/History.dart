import 'dart:developer';

import 'package:better_days_flutter/main.dart';
import 'package:better_days_flutter/models/history_entry.dart';
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

    var items = List<ListItem>.generate(sortedEntries.length, (i) {
      return MessageItem(sortedEntries[i]);
    });

    var currentMonthOffset = 0;
    sortedEntries.asMap().forEach((i, e) {
      if (i > 0) {
        if (sortedEntries[i].date.month != sortedEntries[i - 1].date.month) {
          items.insert(i + currentMonthOffset,
              HeadingItem(DateFormat.MMMM().format(sortedEntries[i].date)));
          currentMonthOffset++;
        }
      }
    });

    // return HeadingItem(DateFormat.MMMM().format(sortedEntries[i].date));

    // var items = List<ListItem>.generate(sortedEntries.length, (i) {
    //   if (i > 0) {
    //     if (sortedEntries[i].date.month != sortedEntries[i - 1].date.month) {
    //       return HeadingItem(DateFormat.MMMM().format(sortedEntries[i].date));
    //     } else {
    //       return MessageItem(sortedEntries[i]);
    //     }
    //   } else {
    //     return MessageItem(sortedEntries[i]);
    //   }
    // });

    items.insert(
        0,
        HeadingItem(DateTime.now().month == sortedEntries[0].date.month
            ? "This month"
            : DateFormat.MMMM().format(sortedEntries[0].date)));

    // final List<Widget> testHistoryEntries = <Widget>[
    //   for (var entry in sortedEntries)
    //     Dismissible(
    //         onDismissed: (direction) {
    //           state.removeEntry(entry);
    //           ScaffoldMessenger.of(context).removeCurrentSnackBar();
    //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //               content: Text(
    //                   "Entry at ${DateFormat.yMMMd().format(entry.date)} removed")));
    //         },
    //         key: Key(entry.date.toString()),
    //         child: HistoryCard(entry: entry))
    // ];

    //TODO: Fix not updating instantly
    return state.historyEntries.isNotEmpty
        ? ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return item.buildTitle(context);
            },
          )
        : const Center(child: Text("No entries yet"));
  }
}

/// The base class for the different types of items the list can contain.
abstract class ListItem {
  /// The title line to show in a list item.
  Widget buildTitle(BuildContext context);
}

/// A ListItem that contains data to display a heading.
class HeadingItem implements ListItem {
  final String heading;

  HeadingItem(this.heading);

  @override
  Widget buildTitle(BuildContext context) {
    return Text(
      heading,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }
}

/// A ListItem that contains data to display a message.
class MessageItem implements ListItem {
  final HistoryEntry entry;

  MessageItem(this.entry);

  @override
  Widget buildTitle(BuildContext context) => HistoryCard(entry: entry);
}
