import 'package:flutter/material.dart';

enum Mode { today, otherDay }

class EvaluateDay extends StatelessWidget {
  const EvaluateDay({super.key, this.mode = Mode.today});
  final Mode mode;

  @override
  Widget build(BuildContext context) {
    String modeText = mode == Mode.today ? "Evaluate this day" : "Evaluate day";

    return Scaffold(
      appBar: AppBar(title: Text(modeText)),
      body: const Text("Evaluate day"),
    );
  }
}
