import 'dart:math';

import 'package:better_days_flutter/models/history_entry.dart';
import 'package:better_days_flutter/screens/history.dart';
import 'package:better_days_flutter/screens/profile.dart';
import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: "Better days",
        home: const MainPage(),
        theme: ThemeData(
            useMaterial3: true,
            colorScheme:
                ColorScheme.fromSeed(seedColor: Colors.green.shade200)),
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  //Mock initialize history entries
  var historyEntries = <HistoryEntry>[
    for (int i = 0; i < 20; i++)
      HistoryEntry(
          date: DateTime.now().subtract(Duration(days: i)),
          score:
              double.parse((Random().nextDouble() * 9 + 1).toStringAsFixed(1)))
  ];

  void addEntry(HistoryEntry entry) {
    historyEntries.add(entry);
    notifyListeners();
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var _selectedIndex = 0;

  static const List<Widget> _mainPageScreens = <Widget>[
    Home(),
    History(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        floatingActionButton: _selectedIndex == 1
            ? FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () =>
                    state.addEntry(HistoryEntry(date: DateTime(2023, 12, 23))))
            : null,
        appBar: AppBar(centerTitle: true, title: const Text("Better days")),
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
