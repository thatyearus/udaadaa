import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/detail/my_record_view.dart';
import 'package:udaadaa/view/home/report_view.dart';
import 'package:udaadaa/view/onboarding/eighth_view.dart';
import 'package:udaadaa/widgets/last_record.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/widgets/report_summary.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  late PageController _pageController;
  late PageController _sectionController;

  int _selectedIndex = 0;

  void _onButtonTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _sectionController = PageController();
    context.read<AuthCubit>().setFCMToken();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SelectButton(
            selectedIndex: _selectedIndex,
            onSelect: _onButtonTapped,
          ),
          Expanded(
            child: _selectedIndex == 0
                ? const ChallengeHomeView()
                : ReportHomeView(pageController: _pageController),
          ),
        ],
      ),
    );
  }
}

class SelectButton extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;

  const SelectButton({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(color: AppColors.neutral[300]),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => onSelect(0),
              child: Text(
                '챌린지',
                style: TextStyle(
                  color: selectedIndex == 0
                      ? AppColors.primary
                      : AppColors.neutral[500],
                  fontWeight:
                      selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            TextButton(
              onPressed: () => onSelect(1),
              child: Text(
                '리포트',
                style: TextStyle(
                  color: selectedIndex == 1
                      ? AppColors.primary
                      : AppColors.neutral[500],
                  fontWeight:
                      selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        Divider(color: AppColors.neutral[300]),
      ],
    );
  }
}

class ChallengeHomeView extends StatelessWidget {
  const ChallengeHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const NonChallengerView();
  }
}

class ChallengerView extends StatelessWidget {
  const ChallengerView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('ChallengerView'),
    );
  }
}

class NonChallengerView extends StatelessWidget {
  const NonChallengerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Analytics().logEvent(
            "홈_챌린지_참여하기",
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EighthView()),
          );
        },
        child: const Text('챌린지 참여하기'),
      ),
    );
  }
}

class ReportHomeView extends StatelessWidget {
  final PageController _pageController;
  const ReportHomeView({super.key, required PageController pageController})
      : _pageController = pageController;

  @override
  Widget build(BuildContext context) {
    final myFeedsLength =
        context.select<FeedCubit, int>((cubit) => cubit.getMyFeeds.length);
    return RefreshIndicator(
      onRefresh: () {
        return Future.wait([
          context.read<FeedCubit>().fetchMyFeeds(),
          //context.read<FeedCubit>().fetchHomeFeeds(),
          context.read<ProfileCubit>().getMyTodayReport(),
        ]);
      },
      child: SingleChildScrollView(
        padding: AppSpacing.edgeInsetsL,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child: PageView.builder(
                controller: _pageController,
                itemCount: min(3, myFeedsLength),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Analytics().logEvent(
                        "홈_최근기록",
                        parameters: {"최근기록_페이지": (index + 1).toString()},
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MyRecordView(initialPage: index),
                        ),
                      );
                    },
                    child: LastRecord(page: index),
                  );
                },
              ),
            ),
            AppSpacing.verticalSizedBoxL,
            GestureDetector(
              child: const ReportSummary(),
              onTap: () {
                Analytics().logEvent(
                  "홈_리포트",
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportView()),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
