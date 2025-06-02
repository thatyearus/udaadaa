import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/widgets/feed.dart';

class FriendRecordView extends StatelessWidget {
  final int initialPage;
  final String friendUserId;

  const FriendRecordView({
    super.key,
    required this.initialPage,
    required this.friendUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.white,
      ),
      body: Center(
        child: FriendFeedPageView(
          initialPage: initialPage,
          friendUserId: friendUserId,
        ),
      ),
    );
  }
}

class FriendFeedPageView extends StatefulWidget {
  final int initialPage;
  final String friendUserId;

  const FriendFeedPageView({
    super.key,
    required this.initialPage,
    required this.friendUserId,
  });

  @override
  FeedPageViewState createState() => FeedPageViewState();
}

class FeedPageViewState extends State<FriendFeedPageView> {
  late PageController _pageController;
  List<Feed> friendFeeds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (friendFeeds.isEmpty) {
      return const Center(
        child: Text(
          '게시물이 없습니다.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: friendFeeds.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) {
        final feed = friendFeeds[index];
        return ImageCard(
          feed: feed,
          isMyPage: false,
          onReactionPressed: () {},
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
