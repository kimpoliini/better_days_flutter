import 'dart:developer';
import 'dart:ui';

import 'package:better_days_flutter/models/history_entry.dart';
import 'package:better_days_flutter/states/app_state.dart';
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
  bool isNoteHidden = false;
  late HistoryEntry entry;

  final headerStyle =
      const TextStyle(fontSize: 18, fontWeight: FontWeight.w400);

  final ExpansionTileController controller = ExpansionTileController();

  @override
  Widget build(BuildContext context) {
    entry = widget.entry;

    setState(() {
      isNoteHidden = entry.isDescriptionHidden;
    });

    RoundedRectangleBorder rrb =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0));
    double cardPadding = 16.0;
    bool hasNote = entry.description != null;
    double noteBlur = isNoteHidden ? 4.0 : 0.0;

    Text textWidget = Text(hasNote ? entry.description! : "No description.",
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: hasNote ? 16.0 : 14.0,
            fontWeight: FontWeight.w300,
            fontStyle: FontStyle.italic));

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
              Theme(
                data: Theme.of(context)
                    .copyWith(disabledColor: Colors.transparent),
                child: Stack(children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: textWidget),
                  ClipRect(
                    child: ExpansionTile(
                      maintainState: true,
                      enabled: false,
                      title: BackdropFilter(
                          filter: ImageFilter.blur(
                              sigmaX: noteBlur, sigmaY: noteBlur),
                          child: textWidget),
                      dense: !hasNote,
                      controller: controller,
                      tilePadding: EdgeInsets.zero,
                      iconColor: Colors.transparent,
                      collapsedIconColor: Colors.transparent,
                      childrenPadding:
                          EdgeInsets.only(top: 0, bottom: cardPadding / 2),
                      children: [
                        Row(children: getButtonRow()),
                      ],
                    ),
                  ),
                ]),
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

  List<Widget> getButtonRow() {
    Color green = Colors.green.shade300;
    double iconSize = 24;
    double containerSize = 36;

    return [
      SizedBox(
        width: containerSize,
        height: containerSize,
        child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            iconSize: iconSize,
            onPressed: () {
              toggleNoteHidden();
            },
            icon: Icon(isNoteHidden ? Icons.visibility_off : Icons.visibility,
                color: green)),
      ),
      SizedBox(
        width: containerSize,
        height: containerSize,
        child: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {},
          icon: Icon(Icons.edit, color: green),
          iconSize: iconSize,
        ),
      ),
      const Spacer(),
      SizedBox(
        width: containerSize,
        height: containerSize,
        child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              _showDeleteEntryDialog(context, entry);
            },
            icon: const Icon(Icons.delete),
            color: Colors.red.shade400,
            iconSize: iconSize),
      )
    ];
  }

  void toggleNoteHidden() => setState(() {
        HistoryEntry newEntry = entry;
        newEntry.isDescriptionHidden = !entry.isDescriptionHidden;

        updateHistoryItem(entry, newEntry);
        isNoteHidden = !isNoteHidden;
      });
}

Future<void> _showDeleteEntryDialog(
    BuildContext context, HistoryEntry entry) async {
  String date = DateFormat.MMMMEEEEd().format(entry.date);

  return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove entry?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Remove the entry on $date?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            TextButton(
              child:
                  Text('REMOVE', style: TextStyle(color: Colors.red.shade400)),
              onPressed: () async {
                await deleteHistoryItem(entry);

                if (context.mounted) {
                  Provider.of<AppState>(context, listen: false)
                      .updateHistoryEntries();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      });
}
