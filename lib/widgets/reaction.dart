import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/models/reaction.dart';

class ReactionButtonsContainer extends StatelessWidget {
  final String feedId;

  const ReactionButtonsContainer({
    super.key,
    required this.feedId,
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
            feedId: feedId,
            label: "잘했어요",
            reactionField: ReactionType.good,
            emoji: "😆",
          ),
          ReactionButton(
            feedId: feedId,
            label: "응원해요",
            reactionField: ReactionType.cheerup,
            emoji: "🥳",
          ),
          ReactionButton(
            feedId: feedId,
            label: "흠..",
            reactionField: ReactionType.hmmm,
            emoji: "🧐",
          ),
          ReactionButton(
            feedId: feedId,
            label: "안돼요!",
            reactionField: ReactionType.nope,
            emoji: "🙅🏻‍♀️️",
          ),
          ReactionButton(
            feedId: feedId,
            label: "멋져요",
            reactionField: ReactionType.awesome,
            emoji: "👍🏻",
          ),
        ],
      ),
    );
  }
}

class ReactionButton extends StatelessWidget {
  final String feedId;
  final String label;
  final ReactionType reactionField;
  final String emoji;

  const ReactionButton({
    super.key,
    required this.feedId,
    required this.label,
    required this.reactionField,
    required this.emoji,
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
          onPressed: () =>
              context.read<FeedCubit>().addReaction(feedId, reactionField),
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
