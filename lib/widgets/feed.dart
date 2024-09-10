import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/models/reaction.dart';
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
          final image = feeds[index];
          return ImageCard(
            image: image,
            onReactionPressed: _addReaction,
          );
        });
  }

  Future<void> _addReaction(String imgId, ReactionType reaction) async {
    context.read<FeedCubit>().addReaction(imgId, reaction);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class ImageCard extends StatefulWidget {
  final Feed image;
  final Function(String imgId, ReactionType reactionField) onReactionPressed;

  const ImageCard({
    super.key,
    required this.image,
    required this.onReactionPressed,
  });

  @override
  _ImageCardState createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ImageDisplay(imageUrl: widget.image.imageUrl!),
        ReactionButtonsOverlay(
          image: widget.image,
        ),
        const Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.all(16.0), // 여백 설정
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Column 크기 최소화
              children: [
                Text(
                  '맛있는건 착하다', // 작성자 정보
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8), // 작성자와 제목 사이의 간격
                Text(
                  '#아침 너무 맛있어서 미치겠읍니다 !', // 제목 정보
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
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
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}

class ReactionButtonsOverlay extends StatefulWidget {
  final Feed image;

  const ReactionButtonsOverlay({
    super.key,
    required this.image,
  });

  @override
  _ReactionButtonsOverlayState createState() => _ReactionButtonsOverlayState();
}

class _ReactionButtonsOverlayState extends State<ReactionButtonsOverlay> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: ReactionButtonsContainer(
          image: widget.image,
        ),
      ),
    );
  }
}
