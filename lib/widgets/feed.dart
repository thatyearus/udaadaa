import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:udaadaa/models/image.dart';
import 'package:udaadaa/widgets/reaction.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedPageView extends StatefulWidget {
  final List<ImageModel> images;

  const FeedPageView({
    Key? key,
    required this.images,
  }) : super(key: key);

  @override
  _FeedPageViewState createState() => _FeedPageViewState();
}

class _FeedPageViewState extends State<FeedPageView> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          final image = widget.images[index];
          return ImageCard(
            image: image,
            onReactionPressed: _addReaction,
          );
        }
    );
  }

  Future<void> _addReaction(int img_id, String reaction) async {
    final supabase = Supabase.instance.client;
    final data = await supabase
        .from('images')
        .select(reaction)
        .eq('id', img_id)
        .single();
    print(data.values.first);

    await supabase
        .from('images')
        .update({ reaction: data.values.first+1})
        .eq('id', img_id);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}


class ImageCard extends StatefulWidget {
  final ImageModel image;
  final Function(int imgId, String reactionField) onReactionPressed;

  const ImageCard({
    Key? key,
    required this.image,
    required this.onReactionPressed,
  }) : super(key: key);

  @override
  _ImageCardState createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ImageDisplay(imageUrl: widget.image.imgUrl),
        ReactionButtonsOverlay(
          image: widget.image,
          onReactionPressed: widget.onReactionPressed,
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(16.0), // 여백 설정
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Column 크기 최소화
              children: [
                Text(
                  '맛있는건 착하다', // 작성자 정보
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8), // 작성자와 제목 사이의 간격
                Text(
                  '#아침 너무 맛있어서 미치겠읍니다 !', // 제목 정보
                  style: const TextStyle(
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

  const ImageDisplay({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }
}

class ReactionButtonsOverlay extends StatefulWidget {
  final ImageModel image;
  final Function(int imgId, String reactionField) onReactionPressed;

  const ReactionButtonsOverlay({
    Key? key,
    required this.image,
    required this.onReactionPressed,
  }) : super(key: key);

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
          onReactionPressed: widget.onReactionPressed,
        ),
      ),
    );
  }
}
