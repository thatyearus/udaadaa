import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/models/reaction.dart';
import 'package:udaadaa/utils/constant.dart';

class LastRecord extends StatelessWidget {
  final int page;
  const LastRecord({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    final myFeedRecord = context.select<FeedCubit, List<Feed>>(
      (cubit) => cubit.getMyFeeds,
    );
    final date = myFeedRecord.isEmpty ? null : myFeedRecord[page].createdAt;
    final year = (date != null) ? date.year : "";
    final month = (date != null) ? date.month : "";
    final day = (date != null) ? date.day : "";

    int countReaction(ReactionType reactionType) {
      return myFeedRecord.isEmpty || myFeedRecord[page].reaction == null
          ? 0
          : myFeedRecord[page]
              .reaction!
              .where((element) => element.type == reactionType)
              .length;
    }

    final reaction1 = countReaction(ReactionType.good);
    final reaction2 = countReaction(ReactionType.cheerup);
    final reaction3 = countReaction(ReactionType.hmmm);
    final reaction4 = countReaction(ReactionType.nope);
    final reaction5 = countReaction(ReactionType.awesome);

    return myFeedRecord.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Container(
            decoration: BoxDecoration(
              color: AppColors.neutral[0],
              border: Border.all(color: AppColors.primary[100]!),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary[100]!,
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            padding: AppSpacing.edgeInsetsM,
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        width: 100,
                        height: 100,
                        imageUrl: myFeedRecord[page].imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    AppSpacing.horizontalSizedBoxM,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("내 최근 기록",
                            style: AppTextStyles.headlineMedium(
                                const TextStyle(color: AppColors.primary))),
                        AppSpacing.verticalSizedBoxS,
                        Text(myFeedRecord[page].review,
                            style: AppTextStyles.textTheme.titleSmall),
                        AppSpacing.verticalSizedBoxXxs,
                        Text("작성일 : $year.$month.$day",
                            style: AppTextStyles.textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
                AppSpacing.verticalSizedBoxXxs,
                Divider(
                  color: AppColors.neutral[300],
                  thickness: 1,
                ),
                AppSpacing.verticalSizedBoxXxs,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text("😆", style: AppTextStyles.textTheme.displayLarge),
                        Text('$reaction1',
                            style: AppTextStyles.textTheme.bodyLarge),
                      ],
                    ),
                    Column(
                      children: [
                        Text("🥳", style: AppTextStyles.textTheme.displayLarge),
                        Text('$reaction2',
                            style: AppTextStyles.textTheme.bodyLarge),
                      ],
                    ),
                    Column(
                      children: [
                        Text("🧐", style: AppTextStyles.textTheme.displayLarge),
                        Text('$reaction3',
                            style: AppTextStyles.textTheme.bodyLarge),
                      ],
                    ),
                    Column(
                      children: [
                        Text("🙅🏻‍♀️",
                            style: AppTextStyles.textTheme.displayLarge),
                        Text('$reaction4',
                            style: AppTextStyles.textTheme.bodyLarge),
                      ],
                    ),
                    Column(
                      children: [
                        Text("👍🏻",
                            style: AppTextStyles.textTheme.displayLarge),
                        Text('$reaction5',
                            style: AppTextStyles.textTheme.bodyLarge),
                      ],
                    ),
                  ],
                )
              ],
            ),
          );
  }
}
