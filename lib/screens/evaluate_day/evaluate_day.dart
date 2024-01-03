import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum DayMode { today, otherDay }

// class EvaluationModeState extends ChangeNotifier {

// }

class EvaluateDay extends StatefulWidget {
  const EvaluateDay({super.key, this.mode = DayMode.today});
  final DayMode mode;

  @override
  State<StatefulWidget> createState() => _EvaluateDayState();
}

class _EvaluateDayState extends State<EvaluateDay> {
  bool isSimpleMode = true;
  DateTime? selectedDate;

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
        widget.mode == DayMode.today ? "Evaluate your day" : "Evaluate day";

    return Scaffold(
      appBar: AppBar(title: Text(modeText)),
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
                  text: selectedDate != null
                      ? DateFormat.yMMMEd().format(selectedDate!)
                      : "Choose date",
                  icon: Icons.calendar_month,
                  onTap: () async {
                    var selected = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2000, 1),
                        lastDate: DateTime.now());
                    if (selected != null) _setDate(selected);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleButton extends StatelessWidget {
  SimpleButton({super.key, this.text, this.onTap, this.icon});

  String? text;
  VoidCallback? onTap;
  IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          onTap: onTap ?? () {},
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon),
                const SizedBox(
                  width: 8,
                ),
                Text(text ?? ""),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
