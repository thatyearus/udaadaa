import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/detail/my_record_view.dart';
import 'package:udaadaa/view/form/food_form_view.dart';
import 'package:udaadaa/widgets/last_record.dart';

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
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        width: double.infinity,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FoodFormView(),
              ),
            );
          },
          label: Text(
            '반응 받으러 가기',
            style: AppTextStyles.textTheme.headlineLarge,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
