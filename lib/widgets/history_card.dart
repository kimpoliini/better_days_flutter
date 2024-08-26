import 'dart:developer';

import 'package:better_days_flutter/models/history_entry.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HistoryCard extends StatefulWidget {
  const HistoryCard({super.key, required this.entry});
  final HistoryEntry entry;

  @override
  State<StatefulWidget> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> {
  // const HistoryCard({super.key, required this.entry});
  bool isExpanded = false;
  late HistoryEntry entry;

  final headerStyle =
      const TextStyle(fontSize: 18, fontWeight: FontWeight.w400);

  final ExpansionTileController controller = ExpansionTileController();

  @override
  Widget build(BuildContext context) {
    entry = widget.entry;
    var rrb = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0));
    double cardPadding = 16.0;
    bool hasNote = entry.description != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: rrb,
      child: InkWell(
        onTap: () {
          if (controller.isExpanded) {
            controller.collapse();
          } else {
            controller.expand();
          }
        },
        customBorder: rrb,
        child: Padding(
          padding: EdgeInsets.only(
              left: cardPadding,
              top: cardPadding,
              right: cardPadding,
              bottom: hasNote ? 6.0 : 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getDateText(),
                style: headerStyle,
              ),
              IgnorePointer(
                ignoring: true,
                child: ExpansionTile(
                  title: Text(
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    hasNote ? entry.description! : "No description.",
                    style: TextStyle(
                        fontSize: hasNote ? 16.0 : 14.0,
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic),
                  ),
                  dense: !hasNote,
                  controller: controller,
                  tilePadding: EdgeInsets.zero,
                  iconColor: Colors.transparent,
                  collapsedIconColor: Colors.transparent,
                  childrenPadding: EdgeInsets.only(
                      top: cardPadding / 2, bottom: cardPadding),
                  children: [
                    Row(
                      children: [
                        Icon(Icons.visibility, color: Colors.green.shade300),
                        Icon(Icons.edit, color: Colors.green.shade300),
                        const Spacer(),
                        Icon(Icons.delete, color: Colors.red.shade400),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // return Card(
    //   margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    //   child: Padding(
    //     padding: const EdgeInsets.all(20.0),
    //     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    //       Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: [
    //           Text(
    //             isThisMonth
    //                 ? (isThisYear
    //                     ? DateFormat.MMMMEEEEd().format(entry.date)
    //                     : DateFormat.yMMMd().format(entry.date))
    //                 : (isThisYear
    //                     ? DateFormat.MMMEd().format(entry.date)
    //                     : DateFormat.yMMMd().format(entry.date)),
    //             style: headerStyle,
    //           ),
    //           Text(
    //             entry.score?.toString() ?? "--",
    //             style: headerStyle,
    //           )
    //         ],
    //       ),
    //       const SizedBox(
    //         height: 8,
    //       ),
    //       Text(
    //         entry.description ?? "No description.",
    //       )
    //     ]),
    //   ),
    // );
  }

  String getDateText() {
    bool isThisYear = DateTime.now().year == entry.date.year;
    bool isThisMonth = DateTime.now().month == entry.date.month;

    return isThisMonth
        ? (isThisYear
            ? DateFormat.MMMMEEEEd().format(entry.date)
            : DateFormat.yMMMd().format(entry.date))
        : (isThisYear
            ? DateFormat.MMMEd().format(entry.date)
            : DateFormat.yMMMd().format(entry.date));
  }
}
