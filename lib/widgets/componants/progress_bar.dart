import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar(
      {Key key,
      @required this.progressValue,
      this.taskText,
      this.taskText1,
      this.radius})
      : super(key: key);

  final double progressValue;
  final String taskText;
  final String taskText1;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                taskText ?? '',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                taskText1 ?? '',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: CircularPercentIndicator(
              radius: radius ?? 140,
              lineWidth: 10.0,
              animation: true,
              percent: progressValue,
              center: Text(
                (progressValue*100).toStringAsFixed(2) + "%",
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: const Color.fromARGB(30, 128, 112, 254),
              circularStrokeCap: CircularStrokeCap.round,
              linearGradient: const LinearGradient(
                  colors: <Color>[Colors.deepPurpleAccent, Colors.deepPurple],
                  stops: <double>[0.25, 0.75])),
        ),
      ],
    );
  }
}
