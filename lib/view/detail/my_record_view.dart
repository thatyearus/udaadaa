import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/widgets/feed.dart';

class MyRecordView extends StatelessWidget {
  final int initialPage;
  const MyRecordView({super.key, required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.white,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 'delete_feed',
                  child: Text('피드 삭제'),
                ),
              ];
            },
            onSelected: (value) {
              switch (value) {
                case 'delete_feed':
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('피드 삭제'),
                          content: const Text('정말 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                '취소',
                                style: AppTextStyles.textTheme.bodyMedium,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<FeedCubit>().deleteMyFeed();
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                Analytics().logEvent("내피드_삭제");
                              },
                              child: Text(
                                '삭제',
                                style: AppTextStyles.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        );
                      });
                  break;
              }
            },
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Center(
        child: MyFeedPageView(initialPage: initialPage),
      ),
    );
  }
}

class MyFeedPageView extends StatefulWidget {
  final int initialPage;
  const MyFeedPageView({
    super.key,
    required this.initialPage,
  });

  @override
  FeedPageViewState createState() => FeedPageViewState();
}

class FeedPageViewState extends State<MyFeedPageView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  Widget build(BuildContext context) {
    final feeds =
        context.select<FeedCubit, List<Feed>>((cubit) => cubit.getMyFeeds);
    if (feeds.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return PageView.builder(
        controller: _pageController,
        itemCount: feeds.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          context.read<FeedCubit>().changeMyFeedPage(index);
          final feed = feeds[index];
          return ImageCard(
            feed: feed,
            isMyPage: true,
            onReactionPressed: () {},
          );
        });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
