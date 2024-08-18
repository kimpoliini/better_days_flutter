import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  const IconText({
    super.key,
    this.icon,
    this.text = "",
    this.iconSpacing = 4.0,
  });

  final Icon? icon;
  final String text;
  final double iconSpacing;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      icon ?? const SizedBox(width: 0.0),
      SizedBox(width: iconSpacing),
      Text(text)
    ]);
  }
}
