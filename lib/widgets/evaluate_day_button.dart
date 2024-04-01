import 'package:flutter/material.dart';

class EvaluateDayButton extends StatelessWidget {
  const EvaluateDayButton(
      {super.key,
      this.text = "",
      this.icon,
      this.color,
      this.filled = true,
      this.onTap});

  final String text;
  final IconData? icon;
  final Color? color;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: filled
          ? StadiumBorder(
              side: BorderSide(color: color ?? Colors.green.shade200))
          : StadiumBorder(
              side:
                  BorderSide(color: color ?? Colors.green.shade200, width: 3)),
      elevation: filled ? 1 : 0,
      color: filled ? color ?? Colors.green.shade200 : Colors.transparent,
      child: InkWell(
        splashColor: color ?? Colors.green.shade300,
        highlightColor: color != null
            ? color!.withOpacity(0.25)
            : Colors.green.shade300.withOpacity(0.25),
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(
            top: 16.0,
            right: icon != null ? 12.0 : 24.0,
            left: 24.0,
            bottom: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: filled
                          ? Colors.white
                          : color ?? Colors.green.shade200),
                  textAlign: TextAlign.center,
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  size: 32,
                  color: filled ? Colors.white : color ?? Colors.green.shade200,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
