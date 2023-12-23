import 'package:flutter/material.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({super.key, required this.date, this.description});

  final DateTime date;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(children: [
        Text(date.toIso8601String()),
        Text(description ?? "No description.")
      ]),
    );
  }
}
