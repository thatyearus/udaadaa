import 'package:flutter/material.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/widgets/feed.dart';

class FriendRecordView extends StatelessWidget {
  final int initialPage;
  final String friendUserId;
  final List<Feed> feeds;

  const FriendRecordView({
    super.key,
    required this.initialPage,
    required this.friendUserId,
    required this.feeds,
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
          feeds: feeds,
        ),
      ),
    );
  }
}

class FriendFeedPageView extends StatefulWidget {
  final int initialPage;
  final String friendUserId;
  final List<Feed> feeds;

  const FriendFeedPageView({
    super.key,
    required this.initialPage,
    required this.friendUserId,
    required this.feeds,
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
    _loadFriendFeeds(widget.feeds);
  }

  Future<void> _loadFriendFeeds(List<Feed> feeds) async {
    try {
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
