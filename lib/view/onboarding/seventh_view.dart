import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/service/shared_preferences.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/main_view.dart';
import 'package:udaadaa/widgets/feed.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';

class SeventhView extends StatelessWidget {
  const SeventhView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.white,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 'block_content',
                  child: Text('컨텐츠 차단'),
                ),
              ];
            },
            onSelected: (value) {
              switch (value) {
                case 'block_content':
                  context.read<FeedCubit>().blockFeedPage();
                  break;
              }
            },
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: const Center(
        child: OnboardingFeedView(),
      ),
    );
  }
}

class OnboardingFeedView extends StatefulWidget {
  const OnboardingFeedView({
    super.key,
  });

  @override
  OnboardingFeedViewState createState() => OnboardingFeedViewState();
}

class OnboardingFeedViewState extends State<OnboardingFeedView> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onScroll);
  }

  void _onScroll() {
    bool isEnd;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS에서는 maxScrollExtent보다 더 큰 값을 확인
      isEnd = _pageController.position.pixels >
          _pageController.position.maxScrollExtent + 20;
    } else {
      // Android에서는 정확히 maxScrollExtent를 확인
      isEnd = _pageController.position.pixels ==
          _pageController.position.maxScrollExtent;
    }
    if (isEnd) {
      Analytics().logEvent("온보딩_종료");
      PreferencesService().setBool('isOnboardingComplete', true);
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0); // 아래에서 위로
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final feeds =
        context.select<FeedCubit, List<Feed>>((cubit) => cubit.getFeeds);
    if (feeds.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return PageView.builder(
        controller: _pageController,
        itemCount: 3,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          final feed = feeds[index];
          context.read<FeedCubit>().changePage(index);
          return ImageCard(
            feed: feed,
            isMyPage: false,
            onReactionPressed: () {
              // go to next page
              Analytics().logEvent(
                "온보딩_피드구경",
                parameters: {"리액션": "클릭"},
              );
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
          );
        });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }
}
