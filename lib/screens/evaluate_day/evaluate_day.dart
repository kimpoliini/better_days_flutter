import 'dart:math';

import 'package:better_days_flutter/schemas/history_item.dart';
import 'package:better_days_flutter/states/app_state.dart';
import 'package:better_days_flutter/widgets/evaluate_day_button.dart';
import 'package:better_days_flutter/widgets/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

enum DayMode { today, otherDay }

class DayScoreEntry {
  DayScoreEntry(this.x, this.y);
  final int x;
  double y;
  Color color = Colors.blue;
}

class EvaluateDay extends StatefulWidget {
  const EvaluateDay({super.key, this.mode = DayMode.today});
  final DayMode mode;

  @override
  State<StatefulWidget> createState() => _EvaluateDayState();
}

class _EvaluateDayState extends State<EvaluateDay> {
  ChartSeriesController? seriesController;
  int selectedPointId = -1;

  bool canPlacePoint = true;
  bool canVibrate = true;
  bool pauseScroll = false;

  bool isSimpleMode = true;
  DateTime? selectedDate;
  double currentSliderValue = 5;
  String note = "";

  List<DayScoreEntry> data = <DayScoreEntry>[
    DayScoreEntry(0, 5),
    DayScoreEntry(24, 5),
  ];

  void _toggleMode() {
    setState(() {
      isSimpleMode = !isSimpleMode;
    });
  }

  void _setDate(date) {
    setState(() {
      selectedDate = date;
    });
  }

  void _addPoint(DayScoreEntry entry) {
    setState(() {
      data.add(entry);

      data.sort(
        (a, b) => a.x.compareTo(b.x),
      );
    });
  }

  void _updatePoint(int index, double newValue, {Color color = Colors.green}) {
    setState(() {
      data[index].y = newValue;
      data[index].color = color;
    });
  }

  void _removePoint(int index) {
    setState(() {
      data.removeAt(index);
    });
  }

  void _removeAllPoints() {
    setState(() {
      data.removeWhere((element) => element.x != 0 && element.x != 24);
      data[0].y = 5;
      data[1].y = 5;
    });
  }

  void _setPauseScroll(bool paused) {
    setState(() {
      pauseScroll = paused;
    });
  }

  @override
  Widget build(BuildContext context) {
    String modeText =
        widget.mode == DayMode.today ? "Evaluate today" : "Evaluate day";
    bool isToday = widget.mode == DayMode.today;
    if (isToday) {
      DateTime now = DateTime.now();
      DateTime today = DateTime.parse(DateFormat("yyyy-MM-dd").format(now));

      _setDate(today);
    }

    var appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: Text(modeText)),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: EvaluateDayButton(
            color: selectedDate != null ? null : Colors.grey,
            text: "Done",
            icon: Icons.check,
            onTap: selectedDate != null
                ? () async {
                    await addDbEntry();

                    appState.updateHistoryEntries();
                    // if (context.mounted)
                    Navigator.pop(context);
                  }
                : null),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: NotificationListener<Notification>(
          onNotification: (notification) {
            canPlacePoint = notification is ScrollStartNotification
                ? false
                : (notification is ScrollEndNotification
                    ? true
                    : canPlacePoint);
            return true;
          },
          child: ListView(
            physics: pauseScroll
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            children: [
              Row(
                children: [
                  RoundedButton(
                    text: isSimpleMode ? "Simple" : "Advanced",
                    icon: Icons.swap_horiz,
                    onTap: _toggleMode,
                  ),
                  RoundedButton(
                    enabled: !isToday,
                    text: isToday
                        ? "Evaluating today"
                        : selectedDate != null
                            ? DateFormat.yMMMEd().format(selectedDate!)
                            : "Choose date",
                    icon: Icons.calendar_month,
                    onTap: isToday
                        ? null
                        : () async {
                            List<DateTime> evaluatedDays = appState
                                .historyEntries
                                .map((e) => e.date)
                                .toList();
                            if (evaluatedDays.length >= 90) {
                              evaluatedDays.sublist(0, 90);
                            }
                            var selected = await showDatePicker(
                                selectableDayPredicate: (DateTime val) {
                                  return !evaluatedDays.contains(val) &&
                                      val.isAfter(DateTime.now().subtract(
                                          const Duration(
                                              days:
                                                  90))); //Limit selection to three months prior
                                },
                                locale: const Locale('en', 'GB'),
                                context: context,
                                firstDate: DateTime(2000, 1),
                                lastDate: DateTime.now());
                            if (selected != null) _setDate(selected);
                          },
                  ),
                ],
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isSimpleMode
                          ? "Choose a score for today"
                          : "Select which part of the day had the most impact, either good or bad"),
                      const SizedBox(
                        height: 8,
                      ),
                      isSimpleMode ? simpleModeLayout() : advancedModeLayout()
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Write a note about today (optional)"),
                        const SizedBox(
                          height: 16,
                        ),
                        TextField(
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          autocorrect: true,
                          maxLines: 4,
                          decoration: const InputDecoration(
                              labelStyle: TextStyle(color: Colors.grey),
                              floatingLabelStyle: TextStyle(),
                              contentPadding: EdgeInsets.all(12.0),
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(),
                              labelText: "How was your day?"),
                          onChanged: (value) => note = value,
                        )
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column simpleModeLayout() {
    return Column(
      children: [
        Slider(
            activeColor: Colors.green.shade200,
            thumbColor: Colors.green.shade200,
            label: currentSliderValue.round().toString(),
            min: 0,
            max: 10,
            divisions: 10,
            value: currentSliderValue,
            onChanged: ((double value) => setState(() {
                  currentSliderValue = value;
                }))),
        const SizedBox(
          height: 4,
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Bad"),
            Text("Decent"),
            Text("Great"),
          ],
        ),
      ],
    );
  }

  Column advancedModeLayout() {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(
          child: Text(
            "Hint: Press the graph to create a point\nDrag a point below the graph to delete it",
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        //Reset button
        Card(
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(12.0)),
            onTap: () {
              _removeAllPoints();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.autorenew,
                size: 32.0,
                color: Colors.green.shade200,
              ),
            ),
          ),
        )
      ]),
      // Row(children: [
      //   Text(
      //       "About what time did you wake up ${isToday ? "today" : "this day"}?"),
      //   const Text("10"),
      // ]),
      // const SizedBox(height: 16.0),
      SfCartesianChart(
          onChartTouchInteractionDown: (tapArgs) {
            final Offset value =
                Offset(tapArgs.position.dx, tapArgs.position.dy);
            final CartesianChartPoint<dynamic> chartPoint =
                seriesController!.pixelToPoint(value);

            var x = (chartPoint.x as double).toInt();
            double y = chartPoint.y;
            y = (y * 2).round() / 2;

            // DayScoreEntry? point =
            //     data.firstWhereOrNull((e) {
            //   var dx = 0.5, dy = 0.5;

            //   return (chartPoint.x > 23.25
            //           ? (e.x == 24)
            //           : (x - dx < e.x + dx &&
            //               x + dx > e.x - dx)) &&
            //       (y - dy < e.y + dy &&
            //           y + dy > e.y - dy);
            // });

            //Gets a list of valid points to be moved
            //when pressing the graph
            List<DayScoreEntry> validPoints = data.where((e) {
              var dx = 1, dy = 0.5;

              return (chartPoint.x > 23.25
                      ? (e.x == 24)
                      : (x - dx < e.x + dx && x + dx > e.x - dx)) &&
                  (y - dy < e.y + dy && y + dy > e.y - dy);
            }).toList();

            //Get differences between
            //press and point positions
            List<double> diffs = validPoints
                .map((e) => e.x > chartPoint.x
                    ? (e.x - chartPoint.x) as double
                    : (chartPoint.x - e.x) as double)
                .toList();

            //Get index of nearest point
            DayScoreEntry? nearestPoint = validPoints.isNotEmpty
                ? validPoints[diffs.indexOf(diffs.reduce(min))]
                : null;

            int? pointId;
            pointId = nearestPoint != null ? data.indexOf(nearestPoint) : -1;

            if (pointId >= 0) {
              selectedPointId = pointId;
              _setPauseScroll(true);
              data[selectedPointId].color = Colors.green;
            }
          },
          //On move interaction
          onChartTouchInteractionMove: (tapArgs) {
            final Offset value =
                Offset(tapArgs.position.dx, tapArgs.position.dy);
            final CartesianChartPoint<dynamic> chartPoint =
                seriesController!.pixelToPoint(value);

            double y = chartPoint.y;
            y = (y * 2).round() / 2;

            //Makes sure points never go below 0 or above 10
            //Maybe move most of this to _updatePoint()?
            if (selectedPointId != -1) {
              if (y < 0 && data[selectedPointId].y != 0) {
                _updatePoint(selectedPointId, 0);
              } else if (y >= 10 && data[selectedPointId].y != 10) {
                _updatePoint(selectedPointId, 10);
              } else if (y <= 10 && y > 0) {
                _updatePoint(selectedPointId, y);
              }
              //Deleting a point
              if (y < -2 &&
                  canVibrate &&
                  data[selectedPointId].x != 24 &&
                  data[selectedPointId].x != 0) {
                canVibrate = false;
                _updatePoint(selectedPointId, 0, color: Colors.red);
                lightVibration();
              } else if (y > -2 && !canVibrate) {
                canVibrate = true;
                if (data[selectedPointId].color != Colors.green) {
                  _updatePoint(selectedPointId, data[selectedPointId].y,
                      color: Colors.green);
                }
              }
            }
          },
          //On up interaction
          onChartTouchInteractionUp: (tapArgs) {
            final Offset value =
                Offset(tapArgs.position.dx, tapArgs.position.dy);

            final CartesianChartPoint<dynamic> chartPoint =
                seriesController!.pixelToPoint(value);

            var x = (chartPoint.x as double).toInt();
            double y = chartPoint.y;
            y = (y * 2).round() / 2;

            if (x > 0 &&
                x < 24 &&
                y > 0 &&
                y <= 10 &&
                !data.any((e) => e.x == x) &&
                selectedPointId == -1 &&
                canPlacePoint) {
              _addPoint(DayScoreEntry(x, y));
            } else if (selectedPointId != -1 &&
                y < -2 &&
                data[selectedPointId].x != 24 &&
                data[selectedPointId].x != 0) {
              _removePoint(selectedPointId);
            } else if (selectedPointId != -1) {
              data[selectedPointId].color = Colors.blue;
            }

            selectedPointId = -1;
            _setPauseScroll(false);
          },
          series: <CartesianSeries>[
            SplineAreaSeries<DayScoreEntry, int>(
                splineType: SplineType.monotonic,
                onRendererCreated: (controller) {
                  seriesController = controller;
                },
                color: Colors.blue.withOpacity(0.5),
                animationDuration: 0,
                borderWidth: 6,
                borderColor: Colors.blue.shade500,
                dataSource: data,
                xValueMapper: (DayScoreEntry data, _) => data.x,
                yValueMapper: (DayScoreEntry data, _) => data.y),
            SplineSeries<DayScoreEntry, int>(
                animationDuration: 0,
                splineType: SplineType.monotonic,
                width: 0.0,
                markerSettings: const MarkerSettings(
                  borderWidth: 8,
                  borderColor: Colors.black,
                  color: Colors.blue,
                  isVisible: true,
                ),
                pointColorMapper: (DayScoreEntry data, _) => data.color,
                dataSource: data,
                xValueMapper: (DayScoreEntry data, _) => data.x,
                yValueMapper: (DayScoreEntry data, _) => data.y),
          ],
          primaryXAxis: NumericAxis(
              minimum: 0,
              maximum: 24,
              interval: 6,
              axisLabelFormatter: (AxisLabelRenderDetails details) =>
                  timeAxis(details)),
          primaryYAxis: NumericAxis(
            minimum: 0,
            maximum: 10,
            interval: 2,
          )),
    ]);
  }

  Future<void> addDbEntry() async {
    Isar db = await openHistoryDatabase();

    final newEntry = HistoryItem()
      ..date = selectedDate!
      ..description = note.isEmpty ? null : note
      ..score = isSimpleMode ? currentSliderValue : averagePointScore(data);

    await db.writeTxn(() async {
      await db.historyItems.put(newEntry);
    });
  }
}

ChartAxisLabel timeAxis(AxisLabelRenderDetails details) {
  return ChartAxisLabel(
      "${details.text.length > 1 ? "" : "0"}${details.text}:00",
      details.textStyle);
}

double averagePointScore(List<DayScoreEntry> entries) {
  double total =
      entries.fold(0, (previousValue, element) => previousValue + element.y);

  return double.parse((total / entries.length).toStringAsFixed(1));
}

Future<void> lightVibration() async {
  await SystemChannels.platform.invokeMethod<void>(
    'HapticFeedback.vibrate',
    'HapticFeedbackType.lightImpact',
  );
}
