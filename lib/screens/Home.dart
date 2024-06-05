import 'dart:developer';

import 'package:better_days_flutter/main.dart';
import 'package:better_days_flutter/models/history_entry.dart';
import 'package:better_days_flutter/screens/evaluate_day/evaluate_day.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../widgets/evaluate_day_button.dart';

class ChartData {
  ChartData(this.x, this.y);
  final int x;
  final double? y;
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    var hasEvaluatedToday = DateFormat.yMd().format(DateTime.now()) ==
        DateFormat.yMd().format(state.historyEntries.isNotEmpty
            ? state.historyEntries.first.date
            : DateTime(1900));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Hi Kim, how was your day?",
                style: TextStyle(
                    color: Colors.green.shade300,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w300)),
          ),
          const MainGraphCard(),
          const SizedBox(
            height: 8,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // const Expanded(child: SizedBox()),
                  Expanded(
                    flex: 3,
                    child: EvaluateDayButton(
                      filled: !hasEvaluatedToday,
                      text: hasEvaluatedToday
                          ? "You have evaluated this day! 🎉"
                          : "Evaluate your day",
                      icon:
                          hasEvaluatedToday ? null : Icons.keyboard_arrow_right,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const EvaluateDay(
                                      mode: DayMode.today,
                                    )));
                      },
                    ),
                  ),
                  // const Expanded(child: SizedBox()),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // const Expanded(child: SizedBox()),
                  Expanded(
                    flex: 3,
                    child: EvaluateDayButton(
                      text: "Evaluate a different day",
                      icon: Icons.keyboard_arrow_right,
                      filled: false,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const EvaluateDay(mode: DayMode.otherDay)));
                      },
                    ),
                  ),
                  // const Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
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
            PastWeekChart(),
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
    var thisWeekEntries = entries
        .getRange(0, entries.length >= 7 ? 7 : entries.length)
        .toList()
        .reversed
        .toList();

    List<ChartData> data = <ChartData>[];

    for (var i = 0; i < 7; i++) {
      var date = DateFormat.yMd()
          .format(DateTime.now().subtract(Duration(days: 6 - i)));

      HistoryEntry? what = thisWeekEntries
          .where((e) => DateFormat.yMd().format(e.date) == date)
          .firstOrNull;

      data.add(ChartData(i + 1, what?.score));
    }
    bool hasData = data.fold(0.0, (prev, e) => prev + (e.y ?? 0)) > 0;

    return SfCartesianChart(
      series: <CartesianSeries>[
        SplineSeries<ChartData, int>(
            animationDuration: 500,
            splineType: SplineType.monotonic,
            markerSettings: MarkerSettings(
                borderWidth: 0,
                height: 20,
                width: 20,
                color: Colors.green.shade200,
                isVisible: true),
            emptyPointSettings: EmptyPointSettings(
              mode: hasData ? EmptyPointMode.drop : EmptyPointMode.gap,
              color: Colors.grey.shade500,
              borderColor: Colors.green.shade200,
              borderWidth: 4,
            ),
            color: Colors.green.shade200,
            width: 10,
            dataSource: data,
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y),
      ],
      primaryXAxis: CategoryAxis(
          interval: 1,
          maximum: 6.33,
          minimum: 0,
          plotOffset: 16,
          axisLabelFormatter: (AxisLabelRenderDetails details) =>
              axis(details, data),
          labelPlacement: LabelPlacement.onTicks),
      primaryYAxis: NumericAxis(
        plotOffset: 16,
        minimum: 0,
        maximum: 10.5,
        interval: 2,
      ),
    );
  }
}

ChartAxisLabel axis(AxisLabelRenderDetails details, List<ChartData> data) {
  var value = int.parse(details.text);
  var day = DateFormat.EEEE()
      .format(DateTime.now().subtract(Duration(days: 7 - value)));
  bool isToday = DateFormat.EEEE().format(DateTime.now()) == day;

  bool isEvaluated = data[value - 1].y != null;

  var style = details.textStyle.copyWith(
    color: isEvaluated ? Colors.green.shade500 : null,
    fontSize: isToday ? 14 : null,
    decoration: isToday ? TextDecoration.underline : null,
    decorationThickness: isToday ? 2 : null,
    decorationStyle: isToday ? TextDecorationStyle.dotted : null,
  );

  return ChartAxisLabel(day.substring(0, 3), style);
}
