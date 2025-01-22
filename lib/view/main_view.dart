import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:badges/badges.dart' as badges;
import 'package:udaadaa/cubit/bottom_nav_cubit.dart';
import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/chat/room_view.dart';
import 'package:udaadaa/view/detail/my_record_view.dart';
import 'package:udaadaa/view/feed/feed_view.dart';
import 'package:udaadaa/view/home/home_view.dart';
import 'package:udaadaa/view/mypage/mypage_view.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/view/register/register_view.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      /*
      const _NavigatorPage(child: HomeView()),
      const _NavigatorPage(child: FeedView()),
      const _NavigatorPage(child: MyPageView()),*/
      const HomeView(),
      const RoomView(),
      const RegisterView(),
      const FeedView(),
      const MyPageView(),
    ];
    final List<String> labels = ['홈', '채팅', '신청', '피드', '마이페이지'];

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<BottomNavCubit, BottomNavState>(
            builder: (context, state) {
          return BlocListener<FeedCubit, FeedState>(
            listener: (context, state) {
              if (state is FeedDetail) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MyRecordView(
                      initialPage: state.index,
                    ),
                  ),
                );
              }
              if (state is FeedPushNotification) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    action: SnackBarAction(
                      label: '바로가기 >',
                      textColor: Colors.yellow,
                      onPressed: () {
                        context.read<FeedCubit>().openFeed(state.feedId);
                      },
                    ),
                    content: Text(state.text),
                  ),
                );
              }
            },
            child: IndexedStack(
              index: BottomNavState.values.indexOf(state),
              children: children,
            ),
          );
        }),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BlocBuilder<BottomNavCubit, BottomNavState>(
            builder: (context, state) {
          final unreadMessagesCount = context.select<ChatCubit, int>(
            (cubit) => cubit.getUnreadMessageCount,
          );
          return BottomNavigationBar(
            selectedItemColor: AppColors.neutral[800],
            unselectedItemColor: AppColors.neutral[400],
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              const BottomNavigationBarItem(
                icon: Icon(FluentIcons.home_24_regular),
                activeIcon: Icon(FluentIcons.home_24_filled),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: badges.Badge(
                  showBadge: unreadMessagesCount > 0,
                  badgeContent: Text(
                    unreadMessagesCount.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  child: const Icon(FluentIcons.chat_multiple_24_regular),
                ),
                activeIcon: badges.Badge(
                  showBadge: unreadMessagesCount > 0,
                  badgeContent: Text(
                    unreadMessagesCount.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  child: const Icon(FluentIcons.chat_multiple_24_filled),
                ),
                label: '채팅',
              ),
              const BottomNavigationBarItem(
                icon: Icon(FluentIcons.add_square_24_regular),
                activeIcon: Icon(FluentIcons.add_square_24_filled),
                label: '신청',
              ),
              const BottomNavigationBarItem(
                icon: Icon(FluentIcons.channel_24_regular),
                activeIcon: Icon(FluentIcons.channel_24_filled),
                label: '피드',
              ),
              const BottomNavigationBarItem(
                icon: Icon(FluentIcons.person_24_regular),
                activeIcon: Icon(FluentIcons.person_24_filled),
                label: '마이페이지',
              ),
            ],
            currentIndex: BottomNavState.values.indexOf(state),
            onTap: (index) {
              Analytics().logEvent(
                "네비게이션바",
                parameters: {"클릭": labels[index]},
              );
              context
                  .read<BottomNavCubit>()
                  .selectTab(BottomNavState.values[index]);
            },
          );
        }),
      ),
      /*
      floatingActionButton: BlocBuilder<BottomNavCubit, BottomNavState>(
        builder: (context, state) {
          if (state == BottomNavState.feed ||
              state == BottomNavState.chat ||
              state == BottomNavState.register) {
            return Container();
          }
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            width: double.infinity,
            child: FloatingActionButton.extended(
              heroTag: 'addFood',
              onPressed: () {
                if (state == BottomNavState.home) {
                  Analytics().logEvent("홈_공감받으러가기");
                } else if (state == BottomNavState.profile) {
                  Analytics().logEvent("마이페이지_공감받으러가기");
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FirstView(),
                  ),
                );
                context.read<BottomNavCubit>().selectTab(BottomNavState.home);
              },
              label: Text(
                '식단 응원 받으러 가기',
                style: AppTextStyles.textTheme.headlineLarge,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,*/
    );
  }
}

/*
class _NavigatorPage extends StatelessWidget {
  final Widget child;

  const _NavigatorPage({required this.child});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => child,
        );
      },
    );
  }
}
*/