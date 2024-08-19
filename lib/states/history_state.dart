import 'dart:developer';
import 'package:better_days_flutter/models/history_entry.dart';
import 'package:better_days_flutter/schemas/history_item.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

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

  HistoryState() {
    updateEntriesAsync();
    fixEntries();
  }

  void updateEntriesAsync() async {
    var newItems = await getHistoryItems();

    historyEntries = newItems
        .map((e) => HistoryEntry(
            date: e.date!, description: e.description, score: e.score))
        .toList();
    // log("updated entries");
    // for (var e in newItems) {
    //   log(e.date.toString());
    // }
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

  void fixEntries() async {
    // if (!fixed) {
    for (var element in historyEntries) {
      // log(element.date.toString());
      var hour = element.date.hour;
      if (hour != 0) {
        element.date = element.date.add(Duration(hours: 24 - hour));
      }
    }
    // }
    // fixed = true;
    // notifyListeners();
    // log("fixed");
  }
}

Future<HistoryItem?> getMostRecentHistoryItem() async {
  final dir = await getApplicationDocumentsDirectory();
  final db = await Isar.open([HistoryItemSchema], directory: dir.path);

  var item = await db.historyItems.where().sortByDateDesc().findFirst();
  await db.close();

  return item;
}

Future<List<HistoryItem>> getHistoryItems() async {
  final dir = await getApplicationDocumentsDirectory();
  final db = await Isar.open([HistoryItemSchema], directory: dir.path);

  var items = await db.historyItems.where().findAll();
  await db.close();

  log("${items.length} items");
  return items;
}

Future<void> deleteHistoryItems() async {
  final dir = await getApplicationDocumentsDirectory();
  final db = await Isar.open([HistoryItemSchema], directory: dir.path);

  await db.writeTxn(() async {
    await db.historyItems.where().deleteAll();
  });

  await db.close();
}
