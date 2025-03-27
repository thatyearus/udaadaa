import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/widgets/category.dart';
import 'package:udaadaa/widgets/reaction.dart';
import 'package:udaadaa/utils/constant.dart';

class FeedPageView extends StatefulWidget {
  const FeedPageView({super.key});

  @override
  FeedPageViewState createState() => FeedPageViewState();
}

class FeedPageViewState extends State<FeedPageView> {
  final PageController _pageController = PageController();
  bool isRefreshing = false;

  void _onCategorySelected(FeedCategory category) {
    context.read<FeedCubit>().changeCategory(category);
  }

  @override
  Widget build(BuildContext context) {
    final feeds =
        context.select<FeedCubit, List<Feed>>((cubit) => cubit.getFeeds);
    if (feeds.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification &&
                  notification.metrics.pixels <=
                      notification.metrics.minScrollExtent &&
                  notification.scrollDelta != null &&
                  notification.scrollDelta! < -5 && // ✅ 강하게 끌어내린 경우만
                  _pageController.page == 0 &&
                  !isRefreshing) {
                setState(() {
                  isRefreshing = true;
                });

                debugPrint("📢 맨 위에서 끌어내려 새로고침 트리거!");
                context.read<FeedCubit>().refreshFeeds().then((_) async {
                  await Future.delayed(
                      const Duration(milliseconds: 1500)); // ⏳ 1.5초 대기

                  if (mounted) {
                    setState(() {
                      isRefreshing = false;
                    });
                  }
                });
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: feeds.length,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) {
                // ✅ 다음 두 개의 이미지를 미리 로드하여 부드러운 UX 제공
                context.read<FeedCubit>().changePage(
                      index,
                    ); // ✅ 페이지가 변경될 때만 호출
                if (index + 1 < feeds.length) {
                  precacheImage(
                    CachedNetworkImageProvider(feeds[index + 1].imageUrl!),
                    context,
                  );
                }
                // if (index + 2 < feeds.length) {
                //   precacheImage(
                //     CachedNetworkImageProvider(feeds[index + 2].imageUrl!),
                //     context,
                //   );
                // }
              },
              itemBuilder: (context, index) {
                final feed = feeds[index];

                return ImageCard(
                  feed: feed,
                  isMyPage: false,
                  onReactionPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                );
              },
            )),

        // // ✅ isRefreshing이 true일 때만 상단에 로딩 표시
        // if (isRefreshing)
        //   SafeArea(
        //     child: Padding(
        //       padding: const EdgeInsets.only(top: 96),
        //       child: SizedBox(
        //         width: 20,
        //         height: 20,
        //         child: CircularProgressIndicator(
        //           strokeWidth: 4,
        //         ),
        //       ),
        //     ),
        //   ),

        // 상단 왼쪽 카테고리 버튼
        CategoryButtonsContainer(onCategorySelected: _onCategorySelected),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class ImageCard extends StatelessWidget {
  final Feed feed;
  final bool isMyPage;
  final VoidCallback onReactionPressed;

  const ImageCard({
    super.key,
    required this.feed,
    required this.isMyPage,
    required this.onReactionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final hashtag = Map<FeedType, String>.from({
      FeedType.breakfast: '# 아침',
      FeedType.lunch: '# 점심',
      FeedType.dinner: '# 저녁',
      FeedType.snack: '# 간식',
      FeedType.exercise: '# 운동',
    });

    return Column(
      children: [
        Expanded(
          flex: 8,
          child: Stack(
            children: [
              ImageDisplay(imageUrl: feed.imageUrl!),
              ReactionButtonsOverlay(
                feed: feed,
                isMyPage: isMyPage,
                onReactionPressed: onReactionPressed,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  feed.profile!.nickname,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    hashtag[feed.type]!,
                    style: TextStyle(
                      color: AppColors.neutral[200],
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feed.review,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ImageDisplay extends StatelessWidget {
  final String imageUrl;

  const ImageDisplay({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.fitWidth,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}

class ReactionButtonsOverlay extends StatelessWidget {
  final Feed feed;
  final bool isMyPage;
  final VoidCallback onReactionPressed;

  const ReactionButtonsOverlay({
    super.key,
    required this.feed,
    required this.isMyPage,
    required this.onReactionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: ReactionButtonsContainer(
          feedId: feed.id!,
          isMyPage: isMyPage,
          onReactionPressed: onReactionPressed,
        ),
      ),
    );
  }
}
