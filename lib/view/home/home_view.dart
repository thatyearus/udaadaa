import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/challenge_cubit.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/detail/my_record_view.dart';
import 'package:udaadaa/view/home/challenge/challenger_view.dart';
import 'package:udaadaa/view/home/challenge/non_challenger_view.dart';
import 'package:udaadaa/view/home/report_view.dart';
import 'package:udaadaa/view/result/result_view.dart';
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
  bool _isChallenger = false;

  int _selectedIndex = 0;

  void _onButtonTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _sectionController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _sectionController = PageController();
    // context.read<AuthCubit>().setFCMToken();
    checkChallenger();
  }

  Future<void> checkChallenger() async {
    _isChallenger = await context.read<ChallengeCubit>().isEntered();
    setState(() {
      _selectedIndex = _isChallenger ? 0 : 1;
      _isChallenger = _isChallenger;
    });
    _sectionController.animateToPage(
      _selectedIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isChallenger = context
        .select<ChallengeCubit, bool>((cubit) => cubit.challenge != null);
    return Scaffold(
      body: BlocListener<ChallengeCubit, ChallengeState>(
        listener: (context, state) {
          if (state is ChallengeEnd) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChallengeResultView(
                  isSuccess: true,
                  endDay: DateTime.now(),
                ),
              ),
            );
          } else if (state is ChallengeSuccess) {
            if (!_isChallenger) return;
            setState(() {
              _selectedIndex = 0;
            });
            _sectionController.animateToPage(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        child: Column(
          children: [
            SelectButton(
              selectedIndex: _selectedIndex,
              onSelect: _onButtonTapped,
            ),
            Expanded(
              child: PageView(
                controller: _sectionController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                children: [
                  ChallengeHomeView(isChallenger: _isChallenger),
                  /* ReportHomeView(pageController: _pageController),*/
                  ReportView(),
                ],
              ),
            ),
          ],
        ),
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
        //Divider(color: AppColors.neutral[300]),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Analytics().logEvent(
                    "홈_챌린지탭",
                  );
                  onSelect(0);
                },
                style: OutlinedButton.styleFrom(
                  overlayColor: AppColors.neutral[500],
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  side: const BorderSide(style: BorderStyle.none),
                ),
                child: Text(
                  '챌린지',
                  style: TextStyle(
                    color: selectedIndex == 0
                        ? AppColors.neutral[700]
                        : AppColors.neutral[500],
                    fontWeight: selectedIndex == 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
            Expanded(
              child: OutlinedButton(
                onPressed: () => onSelect(1),
                style: OutlinedButton.styleFrom(
                  overlayColor: AppColors.neutral[500],
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  side: const BorderSide(style: BorderStyle.none),
                ),
                child: Text(
                  '리포트',
                  style: TextStyle(
                    color: selectedIndex == 1
                        ? AppColors.neutral[700]
                        : AppColors.neutral[500],
                    fontWeight: selectedIndex == 1
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppColors.neutral[500],
                thickness: selectedIndex == 0 ? AppSpacing.xxs : 0.0,
                height: 0,
              ),
            ),
            Expanded(
                child: Divider(
              color: AppColors.neutral[500],
              thickness: selectedIndex == 0 ? 0.0 : AppSpacing.xxs,
              height: 0,
            )),
          ],
        ),
        Divider(color: AppColors.neutral[300], height: 0.0),
      ],
    );
  }
}

class ChallengeHomeView extends StatelessWidget {
  const ChallengeHomeView({super.key, required this.isChallenger});

  final bool isChallenger;

  @override
  Widget build(BuildContext context) {
    return isChallenger ? const ChallengerView() : const NonChallengerView();
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
              child: myFeedsLength != 0
                  ? PageView.builder(
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
                    )
                  : const LastRecord(page: 0),
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
