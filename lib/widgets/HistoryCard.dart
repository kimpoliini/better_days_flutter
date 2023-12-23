import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({super.key, required this.date, this.description});

  final DateTime date;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            DateFormat.MMMMEEEEd().format(date),
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            description ?? "No description.",
          )
        ]),
      ),
    );
  }
}
