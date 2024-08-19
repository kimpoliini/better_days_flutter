import 'package:better_days_flutter/schemas/user.dart';
import 'package:better_days_flutter/states/app_state.dart';
import 'package:better_days_flutter/widgets/icon_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

TextStyle greySmallItalic = TextStyle(
    fontSize: 14.0, color: Colors.grey.shade400, fontStyle: FontStyle.italic);

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
    var state = context.watch<AppState>();
    var user = state.user;

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
                    const SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${user.firstName} ${user.lastName}",
                          style: const TextStyle(fontSize: 20.0),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: user.birthday != null
                                ? IconText(
                                    iconSpacing: 6.0,
                                    icon: Icon(Icons.cake,
                                        color: Colors.green.shade200),
                                    text: DateFormat.yMMMEd()
                                        .format(user.birthday!),
                                  )
                                : (!checkInfo(user)
                                    ? Text("No additional info",
                                        style: greySmallItalic)
                                    : null)),
                      ],
                    )
                  ]),
                  Container(child: getExpandedInfoWidgets(user)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  bool checkInfo(User user) =>
      (user.email != null && user.phone != null && user.address != null);

  Widget? getExpandedInfoWidgets(User user) {
    if (!checkInfo(user)) return null;

    List<Widget> children = <Widget>[];

    children.add(const SizedBox(height: 8.0));

    ExpansionTile widget = ExpansionTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      collapsedShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
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
            children: children,
          ),
        )
      ],
    );

    children.add(const SizedBox(height: 8.0));
    if (user.email != null) {
      children.add(IconText(
          iconSpacing: 6.0,
          icon: Icon(Icons.email, color: Colors.green.shade200),
          text: user.email!));
      children.add(const SizedBox(height: 8.0));
    }

    if (user.phone != null) {
      IconText(
          iconSpacing: 6.0,
          icon: Icon(Icons.phone, color: Colors.green.shade200),
          text: user.phone!);
      children.add(const SizedBox(height: 8.0));
    }

    if (user.address != null) {
      children.add(IconText(
        iconSpacing: 6.0,
        icon: Icon(Icons.home, color: Colors.green.shade200),
        text: user.address!,
      ));
      children.add(const SizedBox(height: 8.0));
    }

    return widget;
  }
}
