import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class ShowNameBanner extends StatelessWidget {
  final String name;
  const ShowNameBanner({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.inversePrimary,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: name, style: textStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(minWidth: 0, maxWidth: double.infinity);

        if (textPainter.size.width > constraints.maxWidth) {
          return SizedBox(
            height: 26, 
            child: Marquee(
              text: name,
              style: textStyle,
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              blankSpace: 50.0,
              velocity: 40.0,
              pauseAfterRound: const Duration(seconds: 2),
              startPadding: 0.0,
              accelerationDuration: const Duration(seconds: 1),
              accelerationCurve: Curves.linear,
              decelerationDuration: const Duration(milliseconds: 500),
              decelerationCurve: Curves.easeOut,
            ),
          );
        } else {
          return SizedBox(
            height: 26,
            child: Text(
              name,
              style: textStyle,
              maxLines: 1,
            ),
          );
        }
      },
    );
  }
}