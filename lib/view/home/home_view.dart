import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/detail/my_record_view.dart';
import 'package:udaadaa/widgets/fab.dart';
import 'package:udaadaa/widgets/last_record.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          return Future.wait([
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyRecordView(initialPage: 0),
                  ),
                );
              },
              child: const LastRecord(page: 0),
            ),
            AppSpacing.verticalSizedBoxL,
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyRecordView(initialPage: 1),
                  ),
                );
              },
              child: const LastRecord(page: 1),
            ),
          ]),
        ),
      ),
      floatingActionButton: const AddFabButton(),
    );
  }
}
