import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/detail/my_record_view.dart';
import 'package:udaadaa/widgets/last_record.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          return Future.wait([
            context.read<FeedCubit>().fetchMyFeeds(),
            context.read<FeedCubit>().fetchHomeFeeds(),
            context.read<ProfileCubit>().getMyTodayReport(),
          ]);
        },
        child: SingleChildScrollView(
          padding: AppSpacing.edgeInsetsL,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(children: [
            GestureDetector(
              onTap: () {
                Analytics().logEvent(
                  "홈_최근기록",
                  parameters: {"최근기록_페이지": "1"},
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyRecordView(initialPage: 0),
                  ),
                );
              },
              child: const LastRecord(page: 0),
            ),
            AppSpacing.verticalSizedBoxXl,
            GestureDetector(
              onTap: () {
                Analytics().logEvent(
                  "홈_최근기록",
                  parameters: {"최근기록_페이지": "2"},
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyRecordView(initialPage: 1),
                  ),
                );
              },
              child: const LastRecord(page: 1),
            ),
            AppSpacing.verticalSizedBoxXl,
            GestureDetector(
              onTap: () {
                Analytics().logEvent(
                  "홈_최근기록",
                  parameters: {"최근기록_페이지": "3"},
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyRecordView(initialPage: 2),
                  ),
                );
              },
              child: const LastRecord(page: 2),
            ),
          ]),
        ),
      ),
    );
  }
}
