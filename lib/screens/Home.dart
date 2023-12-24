import 'package:better_days_flutter/main.dart';
import 'package:better_days_flutter/models/history_entry.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          MainGraphCard(),
        ],
      ),
    );
  }
}

class MainGraphCard extends StatelessWidget {
  const MainGraphCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Past week"),
            SizedBox(
              height: 16,
            ),
            PastWeekChart()
          ],
        ),
      ),
    );
  }
}

class PastWeekChart extends StatelessWidget {
  const PastWeekChart({super.key});

  @override
  Widget build(BuildContext context) {
    var entries = context.watch<AppState>().historyEntries;
    var thisWeekEntries = entries.getRange(0, 7).toList().reversed.toList();

    //Checks if entries are from the past week
    // final date = e.date;
    // var isThisWeek =
    //     DateTime.now().subtract(const Duration(days: 7)).isBefore(date);

    return SfCartesianChart(
      series: <ChartSeries>[
        SplineSeries<HistoryEntry, String>(
            animationDuration: 2000,
            emptyPointSettings: EmptyPointSettings(
                mode: EmptyPointMode.average, color: Colors.red),
            color: Colors.green.shade200,
            width: 10,
            dataSource: thisWeekEntries,
            xValueMapper: (HistoryEntry entry, _) =>
                DateFormat.E().format(entry.date),
            yValueMapper: (HistoryEntry entry, _) => entry.score)
      ],
      primaryXAxis: CategoryAxis(
          interval: 1,
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          labelPlacement: LabelPlacement.onTicks),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: 10,
        interval: 2,
      ),
    );
  }
}
