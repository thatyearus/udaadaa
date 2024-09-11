import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/widgets/feed.dart';

class MyRecordView extends StatelessWidget {
  final int initialPage;
  const MyRecordView({super.key, required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.white,
      ),
      body: Center(
        child: MyFeedPageView(initialPage: initialPage),
      ),
    );
  }
}

class MyFeedPageView extends StatefulWidget {
  final int initialPage;
  const MyFeedPageView({
    super.key,
    required this.initialPage,
  });

  @override
  FeedPageViewState createState() => FeedPageViewState();
}

class FeedPageViewState extends State<MyFeedPageView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  Widget build(BuildContext context) {
    final feeds =
        context.select<FeedCubit, List<Feed>>((cubit) => cubit.getMyFeeds);
    if (feeds.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return PageView.builder(
        controller: _pageController,
        itemCount: feeds.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          final feed = feeds[index];
          return ImageCard(
            feed: feed,
          );
        });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
