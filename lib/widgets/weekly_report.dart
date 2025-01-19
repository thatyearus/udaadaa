import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/widgets/calorie_report.dart';
import 'package:udaadaa/widgets/exercise_report.dart';
import 'package:udaadaa/widgets/weight_report.dart';

class WeeklyReport extends StatefulWidget {
  const WeeklyReport({super.key});

  @override
  State<WeeklyReport> createState() => _WeeklyReportState();
}

class _WeeklyReportState extends State<WeeklyReport> {
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void previousPage() {
    if (_selectedIndex > 0) {
      _pageController.animateToPage(
        _selectedIndex - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _selectedIndex--;
      });
    }
  }

  void nextPage() {
    if (_selectedIndex < 2) {
      _pageController.animateToPage(
        _selectedIndex + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _selectedIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      const CalorieReport(),
      const WeightReport(),
      const ExerciseReport()
    ];
    return SizedBox(
      height: 350,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: pages.length,
              itemBuilder: (context, index) => pages[index],
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _selectedIndex > 0 ? previousPage : null,
                icon: const Icon(FluentIcons.chevron_left_12_regular),
                disabledColor: AppColors.neutral[300],
                color: AppColors.neutral[700],
              ),
              Expanded(
                  child: Text(
                "${_selectedIndex + 1} / 3 페이지",
                textAlign: TextAlign.center,
                style: AppTextStyles.textTheme.bodyMedium,
              )),
              IconButton(
                  onPressed: _selectedIndex < 2 ? nextPage : null,
                  icon: const Icon(FluentIcons.chevron_right_12_regular)),
            ],
          ),
        ],
      ),
    );
  }
}
