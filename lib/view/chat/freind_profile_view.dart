import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/chat/freind_record_view.dart';
import 'package:udaadaa/view/detail/my_record_view.dart';

import '../../utils/analytics/analytics.dart';

class FreindProfileView extends StatefulWidget {
  final String friendUserId;

  const FreindProfileView({
    super.key,
    required this.friendUserId,
  });

  @override
  State<FreindProfileView> createState() => _FreindProfileViewState();
}

class _FreindProfileViewState extends State<FreindProfileView> {
  List<Feed> friendFeeds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriendFeeds();
  }

  Future<void> _loadFriendFeeds() async {
    try {
      final feeds =
          await context.read<FeedCubit>().fetchUserFeeds(widget.friendUserId);
      if (mounted) {
        setState(() {
          friendFeeds = feeds;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: []),
      body: RefreshIndicator(
        onRefresh: _loadFriendFeeds,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.verticalSizedBoxL,
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (friendFeeds.isEmpty)
                const Center(child: Text('게시물이 없습니다.'))
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: friendFeeds.length,
                  itemBuilder: (context, index) {
                    return GridTile(
                      child: GestureDetector(
                        onTap: () {
                          Analytics().logEvent(
                            "친구프로필_피드",
                            parameters: {
                              "피드선택": index,
                              "챌린지상태": context
                                  .read<AuthCubit>()
                                  .getChallengeStatus(),
                            },
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => FriendRecordView(
                                  initialPage: index,
                                  friendUserId: widget.friendUserId),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: CachedNetworkImage(
                                width: double.infinity,
                                height: double.infinity,
                                imageUrl: friendFeeds[index].imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Container(
                                alignment: Alignment.center,
                                width: double.infinity,
                                height: double.infinity,
                                color: AppColors.neutral[500]?.withOpacity(0.5),
                                child: Text(
                                  (friendFeeds[index].calorie != null
                                      ? "${friendFeeds[index].calorie} ${friendFeeds[index].type == FeedType.exercise ? "분" : "kcal"}"
                                      : ""),
                                  style: AppTextStyles.headlineSmall(
                                    TextStyle(
                                      color: AppColors.neutral[200],
                                      shadows: [
                                        Shadow(
                                          color: AppColors.neutral[500]!,
                                          offset: const Offset(0, 1),
                                          blurRadius: 0,
                                        )
                                      ],
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
