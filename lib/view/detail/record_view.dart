import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/widgets/feed.dart';

class RecordView extends StatelessWidget {
  final int stackIndex;
  const RecordView({super.key, required this.stackIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.white,
      ),
      body: Center(
        child: MyFeedPageView(stackIndex: stackIndex),
      ),
    );
  }
}

class MyFeedPageView extends StatefulWidget {
  final int stackIndex;
  const MyFeedPageView({
    super.key,
    required this.stackIndex,
  });

  @override
  FeedPageViewState createState() => FeedPageViewState();
}

class FeedPageViewState extends State<MyFeedPageView> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_pageController.position.pixels >=
        _pageController.position.maxScrollExtent) {
      context.read<FeedCubit>().getMoreHomeFeeds(widget.stackIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final feeds = context.select<FeedCubit, List<Feed>>(
        (cubit) => cubit.getHomeFeeds[widget.stackIndex]);
    if (feeds.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return PageView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
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
