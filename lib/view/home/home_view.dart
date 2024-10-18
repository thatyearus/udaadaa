import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/detail/my_record_view.dart';
import 'package:udaadaa/view/home/report_view.dart';
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

  @override
  Widget build(BuildContext context) {
    final myFeedsLength =
        context.select<FeedCubit, int>((cubit) => cubit.getMyFeeds.length);
    return Scaffold(
      body: RefreshIndicator(
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
                height: MediaQuery.of(context).size.height * 0.3,
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
      ),
    );
  }
}
