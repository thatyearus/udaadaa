import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/widgets/reaction.dart';

class FeedPageView extends StatefulWidget {
  const FeedPageView({
    super.key,
  });

  @override
  FeedPageViewState createState() => FeedPageViewState();
}

class FeedPageViewState extends State<FeedPageView> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final feeds =
        context.select<FeedCubit, List<Feed>>((cubit) => cubit.getFeeds);
    if (feeds.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return PageView.builder(
        controller: _pageController,
        itemCount: feeds.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          final feed = feeds[index];
          context.read<FeedCubit>().changePage(index);
          return ImageCard(
            feed: feed,
            isMyPage: false,
          );
        });
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

  const ImageCard({super.key, required this.feed, required this.isMyPage});

  @override
  Widget build(BuildContext context) {
    final hashtag = Map<FeedType, String>.from({
      FeedType.breakfast: '# 아침',
      FeedType.lunch: '# 점심',
      FeedType.dinner: '# 저녁',
      FeedType.snack: '# 간식',
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
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0), // 여백 설정
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Column 크기 최소화
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  feed.profile!.nickname, // 작성자 정보
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8), // 작성자와 제목 사이의 간격
              Row(
                children: [
                  Text(
                    hashtag[feed.type]!,
                    style: TextStyle(
                      color: AppColors.neutral[200],
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8), // 작성일과 제목 사이의 간격
                  Text(
                    feed.review, // 제목 정보
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
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

  const ReactionButtonsOverlay({
    super.key,
    required this.feed,
    required this.isMyPage,
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
        ),
      ),
    );
  }
}
