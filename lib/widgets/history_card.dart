import 'package:better_days_flutter/models/history_entry.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({super.key, required this.entry});

  final HistoryEntry entry;

  final headerStyle = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    bool isThisYear = DateTime.now().year == entry.date.year;
    bool isThisMonth = DateTime.now().month == entry.date.month;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isThisMonth
                    ? (isThisYear
                        ? DateFormat.MMMMEEEEd().format(entry.date)
                        : DateFormat.yMMMd().format(entry.date))
                    : (isThisYear
                        ? DateFormat.MMMEd().format(entry.date)
                        : DateFormat.yMMMd().format(entry.date)),
                style: headerStyle,
              ),
              Text(
                entry.score?.toString() ?? "--",
                style: headerStyle,
              )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            entry.description ?? "No description.",
          )
        ]),
      ),
    );
  }
}
