import 'dart:ffi';

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
    // var isThisWeek = DateTime.now().subtract(const Duration(days: 7)).isBefore(e.date);

    List<ChartData> data = <ChartData>[];

    // data.add(ChartData(0, 5));

    for (var i = 0; i < 7; i++) {
      var date =
          DateFormat.yMd().format(DateTime.now().subtract(Duration(days: i)));

      HistoryEntry? what = thisWeekEntries
          .where((e) => DateFormat.yMd().format(e.date) == date)
          .firstOrNull;

      data.add(ChartData(i + 1, what?.score));
    }

    return SfCartesianChart(
      series: <CartesianSeries>[
        SplineAreaSeries<ChartData, int>(
            animationDuration: 2000,
            emptyPointSettings: EmptyPointSettings(
              mode: EmptyPointMode.average,
              color: Colors.grey.shade500,
              borderColor: Colors.green.shade200,
              borderWidth: 4,
            ),
            markerSettings: MarkerSettings(
                borderWidth: 0,
                height: 18,
                width: 18,
                color: Colors.green.shade200,
                isVisible: true),
            color: Colors.transparent,
            borderColor: Colors.green.shade200,
            borderWidth: 10,
            dataSource: data,
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y),
      ],
      primaryXAxis: CategoryAxis(
          interval: 1,
          maximum: 6,
          minimum: 0,
          plotOffset: 16,
          axisLabelFormatter: (AxisLabelRenderDetails details) => axis(details),
          labelPlacement: LabelPlacement.onTicks),
      primaryYAxis: NumericAxis(
        plotOffset: 16,
        minimum: 0,
        maximum: 10,
        interval: 2,
      ),
    );
  }
}

ChartAxisLabel axis(AxisLabelRenderDetails details) {
  var weekdays = <String>["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  return ChartAxisLabel(
      weekdays[int.parse(details.text) - 1], details.textStyle);
}

class ChartData {
  ChartData(this.x, this.y);
  final int x;
  final double? y;
}
