import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/utils/constant.dart';

class LastRecord extends StatelessWidget {
  const LastRecord({super.key});

  @override
  Widget build(BuildContext context) {
    final myFeedRecord = context.select<FeedCubit, List<Feed>>(
      (cubit) => cubit.getMyFeeds,
    );
    final date = myFeedRecord.isEmpty ? null : myFeedRecord[0].createdAt;
    final year = (date != null) ? date.year : "";
    final month = (date != null) ? date.month : "";
    final day = (date != null) ? date.day : "";

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
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    width: 100,
                    height: 100,
                    imageUrl: myFeedRecord[0].imageUrl!,
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
                    Text(myFeedRecord[0].review,
                        style: AppTextStyles.textTheme.titleSmall),
                    AppSpacing.verticalSizedBoxXxs,
                    Text("작성일 : $year.$month.$day",
                        style: AppTextStyles.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          );
  }
}
