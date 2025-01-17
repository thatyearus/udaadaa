import 'package:flutter/material.dart';
import 'package:udaadaa/widgets/calorie_report.dart';
import 'package:udaadaa/widgets/exercise_report.dart';
import 'package:udaadaa/widgets/weight_report.dart';

class WeeklyReport extends StatefulWidget {
  const WeeklyReport({super.key});

  @override
  State<WeeklyReport> createState() => _WeeklyReportState();
}

class _WeeklyReportState extends State<WeeklyReport> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: PageView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return const CalorieReport();
            case 1:
              return const WeightReport();
            case 2:
              return const ExerciseReport();
            default:
              return const CalorieReport();
          }
        },
      ),
    );
  }
}
