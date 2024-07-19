import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  IconText({
    super.key,
    this.icon,
    this.text = "",
    this.iconSpacing = 4.0,
  });

  Icon? icon;
  String text;
  double iconSpacing;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      icon ?? const SizedBox(width: 0.0),
      SizedBox(width: iconSpacing),
      Text(text)
    ]);
  }
}
