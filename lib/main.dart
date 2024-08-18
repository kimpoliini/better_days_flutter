import 'dart:developer';

import 'package:better_days_flutter/schemas/history_item.dart';
import 'package:better_days_flutter/screens/settings.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:better_days_flutter/screens/history.dart';
import 'package:better_days_flutter/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/home.dart';
import 'package:provider/provider.dart';

import 'states/history_state.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        var state = HistoryState();
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
    var state = context.watch<HistoryState>();

    state.fixEntries();

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text(_appBarTitle),
            actions: getCurrentTabActions(context, _selectedIndex)),
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

List<Widget>? getCurrentTabActions(BuildContext context, int index) {
  List<Widget> actions = [];

  switch (index) {
    case 2:
      actions = <Widget>[
        IconButton(
          onPressed: () => {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Settings()))
          },
          icon: const Icon(Icons.settings),
        )
      ];
      break;
    case 1:
      actions = <Widget>[
        IconButton(
          onPressed: () => {_showDeleteDialog(context)},
          icon: const Icon(Icons.delete_sweep),
        )
      ];
      break;
    default:
      return null;
  }

  return actions;
}

Future<void> _showDeleteDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Clear history'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Remove all evaluated days?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          TextButton(
            child: const Text('OK'),
            onPressed: () async {
              await deleteHistoryItems();

              if (context.mounted) {
                Provider.of<HistoryState>(context, listen: false)
                    .updateEntriesAsync();
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}

Future<void> deleteHistoryItems() async {
  final dir = await getApplicationDocumentsDirectory();
  final db = await Isar.open([HistoryItemSchema], directory: dir.path);

  await db.writeTxn(() async {
    await db.historyItems.where().deleteAll();
  });

  await db.close();
}

Future<List<HistoryItem>> getHistoryItems() async {
  final dir = await getApplicationDocumentsDirectory();
  final db = await Isar.open([HistoryItemSchema], directory: dir.path);

  var items = await db.historyItems.where().findAll();
  await db.close();

  return items;
}
