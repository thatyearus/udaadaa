import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/detail/my_record_view.dart';
import 'package:udaadaa/view/detail/record_view.dart';
import 'package:udaadaa/view/home/report_view.dart';
import 'package:udaadaa/widgets/fab.dart';
import 'package:udaadaa/widgets/last_record.dart';
import 'package:udaadaa/widgets/report_summary.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeFeeds =
        context.select((FeedCubit feedCubit) => feedCubit.getHomeFeeds);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          return Future.wait([
            context.read<FeedCubit>().fetchHomeFeeds(),
            context.read<ProfileCubit>().getMyTodayReport(),
          ]);
        },
        child: SingleChildScrollView(
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
                child:
                    const LastRecord() /*Container(
                color: AppColors.neutral[100],
                padding: AppSpacing.edgeInsetsM,
                width: double.infinity,
                alignment: Alignment.center,
                child: const Text("내 최근 기록"),
              ),*/
                ),
            AppSpacing.verticalSizedBoxXl,
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportView(),
                  ),
                );
              },
              child: const ReportSummary(),
            ),
            AppSpacing.verticalSizedBoxL,
            if (homeFeeds[2].isNotEmpty)
              Row(children: [
                Expanded(
                  child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return GridTile(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      RecordView(stackIndex: index)));
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: CachedNetworkImage(
                                width: double.infinity,
                                height: double.infinity,
                                imageUrl: homeFeeds[index][0].imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ]),
          ]),
        ),
      ),
      floatingActionButton: const AddFabButton(),
    );
  }
}
