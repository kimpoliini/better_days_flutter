import 'package:better_days_flutter/models/history_entry.dart';
import 'package:better_days_flutter/screens/History.dart';
import 'package:better_days_flutter/screens/Profile.dart';
import 'package:flutter/material.dart';
import 'screens/Home.dart';
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
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  var historyEntries = <HistoryEntry>[];
  var historyCards = <Widget>[];
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

    state.historyEntries = <HistoryEntry>[
      for (int i = 0; i < 20; i++) HistoryEntry(date: DateTime(2017, 9, 7))
    ];

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: AppBar(centerTitle: true, title: const Text("Better days")),
        body: _mainPageScreens.elementAt(_selectedIndex),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: _onItemTapped,
          selectedIndex: _selectedIndex,
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
