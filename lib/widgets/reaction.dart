import 'package:flutter/material.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/models/reaction.dart';

class ReactionButtonsContainer extends StatelessWidget {
  final Feed image;
  final Function(String imgId, ReactionType reactionField) onReactionPressed;

  const ReactionButtonsContainer({
    super.key,
    required this.image,
    required this.onReactionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3), // 반투명한 검은색 배경
        borderRadius: BorderRadius.circular(30), // 둥근 모서리
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ReactionButton(
              imageId: image.id!,
              label: "잘했어요",
              reactionField: ReactionType.good,
              emoji: "😆",
              onPressed: onReactionPressed),
          ReactionButton(
              imageId: image.id!,
              label: "응원해요",
              reactionField: ReactionType.cheerup,
              emoji: "🥳",
              onPressed: onReactionPressed),
          ReactionButton(
              imageId: image.id!,
              label: "흠..",
              reactionField: ReactionType.hmmm,
              emoji: "🧐",
              onPressed: onReactionPressed),
          ReactionButton(
              imageId: image.id!,
              label: "안돼요!",
              reactionField: ReactionType.nope,
              emoji: "🙅🏻‍♀️️",
              onPressed: onReactionPressed),
          ReactionButton(
              imageId: image.id!,
              label: "멋져요",
              reactionField: ReactionType.awesome,
              emoji: "👍🏻",
              onPressed: onReactionPressed),
        ],
      ),
    );
  }
}

class ReactionButton extends StatelessWidget {
  final String imageId;
  final String label;
  final ReactionType reactionField;
  final String emoji;
  final Function(String, ReactionType) onPressed;

  const ReactionButton({
    super.key,
    required this.imageId,
    required this.label,
    required this.reactionField,
    required this.emoji,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Text(
            emoji,
            style: const TextStyle(
                fontSize: 46, color: Colors.white), // 이모티콘 색상 흰색
          ),
          onPressed: () => onPressed(imageId, reactionField),
        ),
        Text(
          label,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold), // 텍스트 색상 흰색
        ),
      ],
    );
  }
}
