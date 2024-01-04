import 'dart:developer';

import 'package:better_days_flutter/main.dart';
import 'package:better_days_flutter/models/history_entry.dart';
import 'package:better_days_flutter/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum DayMode { today, otherDay }

class EvaluateDay extends StatefulWidget {
  const EvaluateDay({super.key, this.mode = DayMode.today});
  final DayMode mode;

  @override
  State<StatefulWidget> createState() => _EvaluateDayState();
}

class _EvaluateDayState extends State<EvaluateDay> {
  bool isSimpleMode = true;
  DateTime? selectedDate;
  double currentSliderValue = 5;
  String note = "";

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

  @override
  Widget build(BuildContext context) {
    String modeText =
        widget.mode == DayMode.today ? "Evaluate today" : "Evaluate day";
    bool isToday = widget.mode == DayMode.today;
    if (isToday) _setDate(DateTime.now());

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
                ? () {
                    appState.addEntry(HistoryEntry(
                        date: selectedDate!,
                        description: note.isEmpty ? null : note,
                        score: currentSliderValue));
                    Navigator.pop(context);
                  }
                : null),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Row(
              children: [
                SimpleButton(
                  text: isSimpleMode ? "Simple" : "Advanced",
                  icon: Icons.swap_horiz,
                  onTap: _toggleMode,
                ),
                SimpleButton(
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
                          var selected = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2000, 1),
                              lastDate: DateTime.now()
                                  .subtract(const Duration(days: 1)));
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
                    isSimpleMode
                        ? Column(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Bad"),
                                  Text("Decent"),
                                  Text("Great"),
                                ],
                              ),
                            ],
                          )
                        : const Text("TODO Advanced mode")
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
    );
  }
}

class SimpleButton extends StatelessWidget {
  const SimpleButton(
      {super.key, this.text, this.onTap, this.icon, this.enabled = true});

  final String? text;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: enabled ? Colors.black : Colors.grey),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  text ?? "",
                  style: TextStyle(color: enabled ? Colors.black : Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
