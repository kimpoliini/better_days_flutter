import 'dart:developer';
import 'package:better_days_flutter/main.dart';
import 'package:better_days_flutter/models/history_entry.dart';
import 'package:flutter/material.dart';

class HistoryState extends ChangeNotifier {
  bool fixed = false;
  String appBarTitle = "Overview";

  var historyEntries = <HistoryEntry>[
    //Mock initialize history entries

    // for (int i = 0; i < 200; i++)
    //   HistoryEntry(
    //       date: DateTime(now.year, now.month, now.day)
    //           .subtract(Duration(days: (i + 1) * 2)),
    //       score:
    //           double.parse((Random().nextDouble() * 9 + 1).toStringAsFixed(1)))
  ];

  void updateEntriesAsync() async {
    var newItems = await getHistoryItems();

    historyEntries = newItems
        .map((e) => HistoryEntry(
            date: e.date!, description: e.description, score: e.score))
        .toList();
    log("updated entries");
    notifyListeners();
  }

  // void addEntry(HistoryEntry entry) {
  //   var dateOnly = DateTime(entry.date.year, entry.date.month, entry.date.day);
  //   entry.date = dateOnly;

  //   historyEntries.add(entry);

  //   historyEntries.sort((a, b) => b.date.compareTo(a.date));
  //   notifyListeners();
  // }

  void removeEntry(HistoryEntry entry) {
    if (historyEntries.contains(entry)) historyEntries.remove(entry);
  }

  void fixEntries() {
    if (!fixed) {
      for (var element in historyEntries) {
        var hour = element.date.hour;
        if (hour != 0) {
          element.date = element.date.add(Duration(hours: 24 - hour));
        }
      }
    }
    fixed = true;
    // log("fixed");
  }
}
