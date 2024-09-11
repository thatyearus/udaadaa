import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/models/reaction.dart';
import 'package:udaadaa/utils/constant.dart';

class ReactionButtonsContainer extends StatelessWidget {
  final String feedId;
  final bool isMyPage;

  const ReactionButtonsContainer({
    super.key,
    required this.feedId,
    required this.isMyPage,
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
            isMyPage: isMyPage,
          ),
          ReactionButton(
            feedId: feedId,
            label: "응원해요",
            reactionField: ReactionType.cheerup,
            emoji: "🥳",
            isMyPage: isMyPage,
          ),
          ReactionButton(
            feedId: feedId,
            label: "흠..",
            reactionField: ReactionType.hmmm,
            emoji: "🧐",
            isMyPage: isMyPage,
          ),
          ReactionButton(
            feedId: feedId,
            label: "안돼요!",
            reactionField: ReactionType.nope,
            emoji: "🙅🏻‍♀️️",
            isMyPage: isMyPage,
          ),
          ReactionButton(
            feedId: feedId,
            label: "멋져요",
            reactionField: ReactionType.awesome,
            emoji: "👍🏻",
            isMyPage: isMyPage,
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
  final bool isMyPage;

  const ReactionButton({
    super.key,
    required this.feedId,
    required this.label,
    required this.reactionField,
    required this.emoji,
    required this.isMyPage, // MyPage 여부 추가
  });

  @override
  Widget build(BuildContext context) {
    final int reactionCount = context.select<FeedCubit, int>(
        (cubit) => cubit.getReactionCount(feedId, reactionField));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // IconButton for Reaction
            IconButton(
              icon: Text(
                emoji,
                style: const TextStyle(
                    fontSize: 46, color: Colors.white), // 이모티콘 색상 흰색
              ),
              onPressed: () =>
                  context.read<FeedCubit>().addReaction(feedId, reactionField),
            ),
            if (isMyPage)
              Positioned(
                top: -20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$reactionCount', // 리액션 수 표시
                    style: AppTextStyles.textTheme.bodyMedium,
                  ),
                ),
              ),
          ],
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
