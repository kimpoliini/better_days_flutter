import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:better_days_flutter/models/history_entry.dart';
import 'package:better_days_flutter/models/main_chart_data.dart';
import 'package:better_days_flutter/screens/evaluate_day/evaluate_day.dart';
import 'package:better_days_flutter/states/app_state.dart';
import 'package:better_days_flutter/widgets/evaluate_day_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

bool hasLoaded = false;

class FutureHome extends StatefulWidget {
  const FutureHome({super.key});

  @override
  State<StatefulWidget> createState() => _FutureHomeState();
}

class _FutureHomeState extends State<FutureHome> {
  String name = "";
  bool hasEvaluatedToday = false;

  Future<bool> _checkData(BuildContext context) async {
    name = context.watch<AppState>().user.firstName ?? "null";

    hasEvaluatedToday = await getMostRecentHistoryItem().then((day) {
      if (day != null) {
        return DateFormat.yMd().format(DateTime.now()) ==
            DateFormat.yMd().format(day.date!);
      } else {
        return false;
      }
    });

    // hasLoaded = true;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _checkData(context),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData || hasLoaded) {
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: layout(context));
          } else if (snapshot.hasError) {
            log(snapshot.error.toString());
            return const Text(":(");
          } else {
            return const Center(child: null);
          }
        });
  }

  ListView layout(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Hi $name, how was your day?",
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
                Expanded(
                  flex: 3,
                  child: EvaluateDayButton(
                    filled: !hasEvaluatedToday,
                    text: hasEvaluatedToday
                        ? "You have evaluated this day! 🎉"
                        : "Evaluate your day",
                    icon: hasEvaluatedToday ? null : Icons.keyboard_arrow_right,
                    onTap: () {
                      if (!hasEvaluatedToday) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const EvaluateDay(
                                      mode: DayMode.today,
                                    )));
                      }
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// class Home extends StatelessWidget {
//   const Home({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var state = context.watch<HistoryState>();
//     var hasEvaluatedToday = DateFormat.yMd().format(DateTime.now()) ==
//         DateFormat.yMd().format(state.historyEntries.isNotEmpty
//             ? state.historyEntries.first.date
//             : DateTime(1900));

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//       child: layout(hasEvaluatedToday, context),
//     );
//   }

//   ListView layout(bool hasEvaluatedToday, BuildContext context) {
//     return ListView(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text("Hi Kim, how was your day?",
//               style: TextStyle(
//                   color: Colors.green.shade300,
//                   fontSize: 24.0,
//                   fontWeight: FontWeight.w300)),
//         ),
//         const MainGraphCard(),
//         const SizedBox(
//           height: 8,
//         ),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Expanded(
//                   flex: 3,
//                   child: EvaluateDayButton(
//                     filled: !hasEvaluatedToday,
//                     text: hasEvaluatedToday
//                         ? "You have evaluated this day! 🎉"
//                         : "Evaluate your day",
//                     icon: hasEvaluatedToday ? null : Icons.keyboard_arrow_right,
//                     onTap: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => const EvaluateDay(
//                                     mode: DayMode.today,
//                                   )));
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Expanded(
//                   flex: 3,
//                   child: EvaluateDayButton(
//                     text: "Evaluate a different day",
//                     icon: Icons.keyboard_arrow_right,
//                     filled: false,
//                     onTap: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) =>
//                                   const EvaluateDay(mode: DayMode.otherDay)));
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

bool hasEvaluatedToday(List<HistoryEntry> entries) {
  return DateFormat.yMd().format(DateTime.now()) ==
      DateFormat.yMd()
          .format(entries.isNotEmpty ? entries.first.date : DateTime(1900));
}

class MainGraphCard extends StatelessWidget {
  const MainGraphCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: PastWeekChart(),
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

    List<MainChartData> data = <MainChartData>[];

    for (var i = 0; i < 7; i++) {
      var date = DateFormat.yMd()
          .format(DateTime.now().subtract(Duration(days: 6 - i)));

      HistoryEntry? what = thisWeekEntries
          .where((e) => DateFormat.yMd().format(e.date) == date)
          .firstOrNull;

      data.add(MainChartData(i + 1, what?.score));
    }

    bool hasData = data.fold(0.0, (prev, e) => prev + (e.y ?? 0)) > 0;
    double blur = hasData ? 0.0 : 2.0;

    List<Widget> stackChildren = <Widget>[
      ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Past week"),
            const SizedBox(
              height: 16,
            ),
            mainChart(hasData, data),
          ],
        ),
      )
    ];
    if (!hasData) {
      stackChildren.add(Positioned.fill(
          child: Center(
        child: Card(
            child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            "No data yet\n\nGet started by\nevaluating your day!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: Colors.grey.shade600),
          ),
        )),
      )));
    }
    return Stack(children: stackChildren);
  }

  SfCartesianChart mainChart(bool hasData, List<MainChartData> data) {
    return SfCartesianChart(
      series: <CartesianSeries>[
        SplineSeries<MainChartData, int>(
            animationDuration: 0,
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
            xValueMapper: (MainChartData data, _) => data.x,
            yValueMapper: (MainChartData data, _) => data.y),
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

ChartAxisLabel axis(AxisLabelRenderDetails details, List<MainChartData> data) {
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
