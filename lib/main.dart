import 'dart:developer';
import 'dart:io';

import 'package:better_days_flutter/schemas/history_item.dart';
import 'package:better_days_flutter/screens/settings.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:better_days_flutter/models/history_entry.dart';
import 'package:better_days_flutter/screens/history.dart';
import 'package:better_days_flutter/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/home.dart';
import 'package:provider/provider.dart';

var now = DateTime.now();
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        var state = AppState();
        state.updateEntriesAsync();
        return state;
      },
      child: MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [
          Locale('en', 'GB'),
          Locale('se', 'SV'),
        ],
        title: "Better Days",
        home: const MainPage(),
        theme: ThemeData(
            dividerColor: Colors.transparent,
            //Fixes InkWell being stuck in a highlighted state when navigating
            pageTransitionsTheme: const PageTransitionsTheme(
                builders: <TargetPlatform, PageTransitionsBuilder>{
                  TargetPlatform.android: ZoomPageTransitionsBuilder(
                      allowEnterRouteSnapshotting: false)
                }),
            useMaterial3: true,
            colorScheme:
                ColorScheme.fromSeed(seedColor: Colors.green.shade200)),
      ),
    );
  }
}

class AppState extends ChangeNotifier {
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
    // for (var he in historyEntries) {
    //   log(he.date.toString());
    // }
    log("updated entries");

    notifyListeners();
  }

  void addEntry(HistoryEntry entry) {
    var dateOnly = DateTime(entry.date.year, entry.date.month, entry.date.day);
    entry.date = dateOnly;

    historyEntries.add(entry);

    historyEntries.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

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
    log("fixed");
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var _selectedIndex = 0;
  String _appBarTitle = "Overview";

  static const List<Widget> _mainPageScreens = <Widget>[
    Home(),
    History(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      switch (index) {
        case 0:
          _appBarTitle = "Overview";
          break;
        case 1:
          _appBarTitle = "History";
          break;
        case 2:
          _appBarTitle = "Profile";
          break;
      }

      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();

    state.fixEntries();

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text(_appBarTitle),
            actions: _selectedIndex == 2
                ? <Widget>[
                    IconButton(
                      onPressed: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Settings()))
                      },
                      icon: const Icon(Icons.settings),
                    )
                  ]
                : null),
        body: _mainPageScreens.elementAt(_selectedIndex),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: _onItemTapped,
          selectedIndex: _selectedIndex,
          indicatorColor: Colors.green.shade200,
          destinations: const <NavigationDestination>[
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: "Home"),
            NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: "History"),
            NavigationDestination(
                icon: Icon(Icons.person_outlined),
                selectedIcon: Icon(Icons.person),
                label: "Profile"),
          ],
        ),
      );
    });
  }
}

Future<List<HistoryItem>> getHistoryItems() async {
  final dir = await getApplicationDocumentsDirectory();
  final db = await Isar.open([HistoryItemSchema], directory: dir.path);
  var items = await db.historyItems.where().findAll();
  await db.close();

  return items;
}
