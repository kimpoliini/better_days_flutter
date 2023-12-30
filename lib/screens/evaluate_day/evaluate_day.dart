import 'package:flutter/material.dart';
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

  void _toggleMode() {
    setState(() {
      isSimpleMode = !isSimpleMode;
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
                Card(
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                    onTap: () => _toggleMode(),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          const Icon(Icons.swap_horiz),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(isSimpleMode ? "Simple" : "Advanced"),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(child: SizedBox())
              ],
            )
          ],
        ),
      ),
    );
  }
}
