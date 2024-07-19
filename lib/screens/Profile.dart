import 'dart:developer';

import 'package:better_days_flutter/widgets/icon_text.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  State<StatefulWidget> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Icon expansionIcon = const Icon(Icons.expand_more);
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(children: [
                    Card(
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(
                                color: Colors.green.shade100, width: 1.0)),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.person,
                            size: 48.0,
                          ),
                        )),
                    const SizedBox(width: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Kim Hellman",
                          style: TextStyle(fontSize: 20.0),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: IconText(
                              iconSpacing: 6.0,
                              icon: Icon(Icons.cake,
                                  color: Colors.green.shade200),
                              text: "May 25, 1999",
                            )),
                      ],
                    )
                  ]),
                  const SizedBox(height: 8.0),
                  ExpansionTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    // leading: SizedBox(width: 0.0),
                    leading: const Text(
                      "Additional information",
                      // "Show ${isExpanded ? "less" : "more"}",
                      style: TextStyle(fontSize: 16),
                    ),
                    // trailing: SizedBox(width: 0.0),
                    // iconColor: Colors.transparent,
                    controlAffinity: ListTileControlAffinity.trailing,
                    title: const Text(""),
                    // tilePadding: EdgeInsets.all(4.0),
                    onExpansionChanged: (expanded) => setState(() {
                      isExpanded = expanded;
                      expansionIcon = expanded
                          ? const Icon(Icons.expand_less)
                          : const Icon(Icons.expand_more);
                    }),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 8.0),
                            IconText(
                              iconSpacing: 6.0,
                              icon: Icon(Icons.email,
                                  color: Colors.green.shade200),
                              text: "kimpas@hotmail.se",
                            ),
                            const SizedBox(height: 8.0),
                            IconText(
                              iconSpacing: 6.0,
                              icon: Icon(Icons.phone,
                                  color: Colors.green.shade200),
                              text: "073 268 73 75",
                            ),
                            const SizedBox(height: 8.0),
                            IconText(
                              iconSpacing: 6.0,
                              icon: Icon(Icons.home,
                                  color: Colors.green.shade200),
                              text: "Kanslivägen 13, 146 37 Tullinge",
                            ),
                            const SizedBox(height: 8.0),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
