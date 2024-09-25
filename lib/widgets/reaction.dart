import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/models/reaction.dart';
import 'package:udaadaa/utils/constant.dart';

class ReactionButtonsContainer extends StatelessWidget {
  final String feedId;
  final bool isMyPage;
  final VoidCallback onReactionPressed;

  const ReactionButtonsContainer({
    super.key,
    required this.feedId,
    required this.isMyPage,
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
            feedId: feedId,
            label: "잘했어요",
            reactionField: ReactionType.good,
            emoji: "😆",
            isMyPage: isMyPage,
            onReactionPressed: onReactionPressed,
          ),
          ReactionButton(
            feedId: feedId,
            label: "응원해요",
            reactionField: ReactionType.cheerup,
            emoji: "🤗",
            isMyPage: isMyPage,
            onReactionPressed: onReactionPressed,
          ),
          ReactionButton(
            feedId: feedId,
            label: "흠..",
            reactionField: ReactionType.hmmm,
            emoji: "🧐",
            isMyPage: isMyPage,
            onReactionPressed: onReactionPressed,
          ),
          ReactionButton(
            feedId: feedId,
            label: "안돼요!",
            reactionField: ReactionType.nope,
            emoji: "🥹",
            isMyPage: isMyPage,
            onReactionPressed: onReactionPressed,
          ),
          ReactionButton(
            feedId: feedId,
            label: "괜찮아요",
            reactionField: ReactionType.awesome,
            emoji: "😉",
            isMyPage: isMyPage,
            onReactionPressed: onReactionPressed,
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
  final VoidCallback onReactionPressed;

  const ReactionButton({
    super.key,
    required this.feedId,
    required this.label,
    required this.reactionField,
    required this.emoji,
    required this.isMyPage,
    required this.onReactionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final Iterable<Reaction> reactions = (isMyPage
        ? context.select<FeedCubit, Iterable<Reaction>>(
            (cubit) => cubit.getReaction(feedId, reactionField))
        : []);

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
                    fontFamily: 'tossface',
                    fontSize: 46,
                    color: Colors.white), // 이모티콘 색상 흰색
              ),
              onPressed: () => (!isMyPage
                  ? context
                      .read<FeedCubit>()
                      .addReaction(feedId, reactionField)
                      .then((value) {
                      logger.d("ReactionButton: onReactionPressed");
                      onReactionPressed();
                    })
                  : showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          padding: AppSpacing.edgeInsetsM,
                          width: double.infinity,
                          color: Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("공감한 사용자",
                                  style: AppTextStyles.textTheme.titleMedium),
                              AppSpacing.sizedBoxM,
                              Divider(
                                color: AppColors.neutral[300],
                                thickness: 1,
                              ),
                              Flexible(
                                child: ListView.builder(
                                  itemCount: reactions.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(reactions
                                              .elementAt(index)
                                              .profile
                                              ?.nickname ??
                                          "no profile"),
                                      trailing: Text(emoji,
                                          style: AppTextStyles
                                              .textTheme.titleMedium),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      })),
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
                    '${reactions.length}', // 리액션 수 표시
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
