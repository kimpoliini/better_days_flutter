import 'dart:developer';
import 'dart:io';
import 'package:better_days_flutter/models/history_entry.dart';
import 'package:better_days_flutter/schemas/history_item.dart';
import 'package:better_days_flutter/schemas/user.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  bool fixed = false;
  String appBarTitle = "Overview";
  User user = User();

  var historyEntries = <HistoryEntry>[
    //Mock initialize history entries

    // for (int i = 0; i < 200; i++)
    //   HistoryEntry(
    //       date: DateTime(now.year, now.month, now.day)
    //           .subtract(Duration(days: (i + 1) * 2)),
    //       score:
    //           double.parse((Random().nextDouble() * 9 + 1).toStringAsFixed(1)))
  ];

  AppState() {
    updateUser();
    updateHistoryEntries();
    fixEntries();
  }

  void updateHistoryEntries() async {
    var newItems = await getHistoryItems();

    historyEntries = newItems
        .map((e) => HistoryEntry(
            date: e.date!,
            description: e.description,
            isDescriptionHidden: e.isDescriptionHidden,
            isBookmarked: e.isBookmarked,
            score: e.score,
            scores: e.scores))
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

  void updateUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User newUser = User();

    newUser.firstName = prefs.getString("firstName") ?? "null";
    newUser.lastName = prefs.getString("lastName") ?? "";

    String? birthdayString = prefs.getString("birthday");
    if (birthdayString != null) {
      newUser.birthday = DateTime.tryParse(birthdayString);
    }

    String? joinedString = prefs.getString("joinedDate");
    if (joinedString != null) {
      newUser.joined = DateTime.tryParse(joinedString);
    }

    user = newUser;
  }
}

Future<void> addHistoryItem(HistoryEntry entry) async {
  Isar db = await openHistoryDatabase();

  final newItem = HistoryItem()
    ..date = entry.date
    ..description = entry.description
    ..isDescriptionHidden = entry.isDescriptionHidden
    ..score = entry.score
    ..scores = entry.scores;

  await db.writeTxn(() async {
    await db.historyItems.put(newItem);
  });
}

Future<HistoryItem?> getMostRecentHistoryItem() async {
  var db = await openHistoryDatabase();

  var count = await db.historyItems.count();
  if (count > 0) {
    log("$count history entries");
    var item = await db.historyItems.where().sortByDateDesc().findFirst();
    return item;
  } else {
    log("history entries is empy");
    return null;
  }
}

Future<List<HistoryItem>> getHistoryItems() async {
  var db = await openHistoryDatabase();

  var items = await db.historyItems.where().findAll();

  log("${items.length} items");
  return items;
}

Future<void> deleteHistoryItems() async {
  var db = await openHistoryDatabase();

  await db.writeTxn(() async {
    await db.historyItems.where().deleteAll();
  });
}

Future<Isar> openHistoryDatabase() async {
  Directory dir = await getApplicationDocumentsDirectory();

  bool isOpen = Isar.getInstance()?.isOpen ?? false;

  return isOpen
      ? Isar.getInstance()!
      : await Isar.open([HistoryItemSchema], directory: dir.path);
}

Future<void> deleteSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  log("Cleared SharedPreferences");
}

Future<void> deleteHistoryItem(HistoryEntry entry) async {
  var db = await openHistoryDatabase();

  await db.writeTxn(() async {
    bool wasDeleted =
        await db.historyItems.where().dateEqualTo(entry.date).deleteFirst();
    if (wasDeleted) log("deleted entry at date ${entry.date}");
  });
}

Future<void> updateHistoryItem(
    HistoryEntry entry, HistoryEntry newEntry) async {
  var db = await openHistoryDatabase();

  await db.writeTxn(() async {
    var item =
        await db.historyItems.where().dateEqualTo(entry.date).findFirst();

    item = HistoryItem() //Same date and id as the original entry
      ..id = item!.id
      ..date = entry.date
      ..description = newEntry.description
      ..isDescriptionHidden = newEntry.isDescriptionHidden
      ..isBookmarked = newEntry.isBookmarked
      ..score = newEntry.score
      ..scores = newEntry.scores;
    await db.historyItems.put(item);

    log("updated entry at date ${entry.date}");
  });
}
