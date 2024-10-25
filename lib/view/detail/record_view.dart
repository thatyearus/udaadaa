import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/widgets/feed.dart';

class RecordView extends StatelessWidget {
  final int stackIndex;
  const RecordView({super.key, required this.stackIndex});

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
                  value: 'block_content',
                  child: Text('컨텐츠 차단'),
                ),
              ];
            },
            onSelected: (value) {
              switch (value) {
                case 'block_content':
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('피드 차단'),
                          content: const Text('정말 차단하시겠습니까?'),
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
                                context
                                    .read<FeedCubit>()
                                    .blockDetailPage(stackIndex);
                                Navigator.of(context).pop();
                                Analytics().logEvent("피드_차단");
                              },
                              child: Text(
                                '차단',
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
        child: DetailFeedPageView(stackIndex: stackIndex),
      ),
    );
  }
}

class DetailFeedPageView extends StatefulWidget {
  final int stackIndex;
  const DetailFeedPageView({
    super.key,
    required this.stackIndex,
  });

  @override
  FeedPageViewState createState() => FeedPageViewState();
}

class FeedPageViewState extends State<DetailFeedPageView> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final feeds = context.select<FeedCubit, List<Feed>>(
        (cubit) => cubit.getHomeFeeds[widget.stackIndex]);
    if (feeds.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return PageView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _pageController,
        itemCount: feeds.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          context
              .read<FeedCubit>()
              .changeHomeFeedPage(widget.stackIndex, index);
          final feed = feeds[index];
          return ImageCard(
            feed: feed,
            isMyPage: false,
            onReactionPressed: () {
              // go to next page
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
          );
        });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
