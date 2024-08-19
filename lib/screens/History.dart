import 'package:better_days_flutter/models/history_entry.dart';
import 'package:better_days_flutter/states/app_state.dart';
import 'package:better_days_flutter/widgets/history_card.dart';
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
      return EntryItem(sortedEntries[i]);
    });

    var currentMonthOffset = 0;
    sortedEntries.asMap().forEach((i, e) {
      if (i > 0) {
        if (sortedEntries[i].date.month != sortedEntries[i - 1].date.month) {
          items.insert(
              i + currentMonthOffset,
              HeadingItem(
                  DateTime.now().year == sortedEntries[i].date.year
                      ? ""
                      : DateFormat.y().format(sortedEntries[i].date),
                  DateFormat.MMMM().format(sortedEntries[i].date)));
          currentMonthOffset++;
        }
      }
    });

    if (items.isNotEmpty) {
      items.insert(
          0,
          HeadingItem(
              DateTime.now().year == sortedEntries[0].date.year
                  ? ""
                  : DateFormat.y().format(sortedEntries[0].date),
              DateTime.now().month == sortedEntries[0].date.month
                  ? "This month"
                  : DateFormat.MMMM().format(sortedEntries[0].date)));
    }

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

abstract class ListItem {
  Widget buildTitle(BuildContext context);
}

class HeadingItem implements ListItem {
  final String year;
  final String month;

  HeadingItem(this.year, this.month);

  @override
  Widget buildTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        year.isNotEmpty
            ? Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
                child: Text(
                  year,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              )
            : const SizedBox.shrink(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            month,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}

class EntryItem implements ListItem {
  final HistoryEntry entry;

  EntryItem(this.entry);

  @override
  Widget buildTitle(BuildContext context) => HistoryCard(entry: entry);
}
