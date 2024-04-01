import 'dart:developer';

import 'package:better_days_flutter/main.dart';
import 'package:better_days_flutter/models/history_entry.dart';
import 'package:better_days_flutter/screens/evaluate_day/evaluate_day.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Hi Kim, how was your day?",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey.shade800),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
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
                  const Expanded(child: SizedBox()),
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
                  const Expanded(child: SizedBox()),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(child: SizedBox()),
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
                  const Expanded(child: SizedBox()),
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
                height: 18,
                width: 18,
                color: Colors.green.shade200,
                isVisible: true),
            emptyPointSettings: EmptyPointSettings(
              mode: hasData ? EmptyPointMode.average : EmptyPointMode.gap,
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
          axisLabelFormatter: (AxisLabelRenderDetails details) => axis(details),
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

ChartAxisLabel axis(AxisLabelRenderDetails details) {
  var today = DateFormat.EEEE().format(DateTime.now());
  var value = int.parse(details.text);
  var day = DateFormat.EEEE()
      .format(DateTime.now().subtract(Duration(days: 7 - value)));

  var dayStyle = day == today
      ? const TextStyle(
          decoration: TextDecoration.underline,
          decorationThickness: 2,
          decorationStyle: TextDecorationStyle.dotted)
      : details.textStyle;

  return ChartAxisLabel(day.substring(0, 3), dayStyle);
}

class EvaluateDayButton extends StatelessWidget {
  const EvaluateDayButton(
      {super.key,
      this.text = "",
      this.icon,
      this.color,
      this.filled = true,
      this.onTap});

  final String text;
  final IconData? icon;
  final Color? color;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: filled
          ? StadiumBorder(
              side: BorderSide(color: color ?? Colors.green.shade200))
          : StadiumBorder(
              side:
                  BorderSide(color: color ?? Colors.green.shade200, width: 3)),
      elevation: filled ? 1 : 0,
      color: filled ? color ?? Colors.green.shade200 : Colors.transparent,
      child: InkWell(
        splashColor: color ?? Colors.green.shade300,
        highlightColor: color != null
            ? color!.withOpacity(0.25)
            : Colors.green.shade300.withOpacity(0.25),
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(
            top: 16.0,
            right: icon != null ? 12.0 : 24.0,
            left: 24.0,
            bottom: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: filled
                          ? Colors.white
                          : color ?? Colors.green.shade200),
                  textAlign: TextAlign.center,
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  size: 32,
                  color: filled ? Colors.white : color ?? Colors.green.shade200,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
