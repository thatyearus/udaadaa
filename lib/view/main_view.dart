import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/bottom_nav_cubit.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/feed/feed_view.dart';
import 'package:udaadaa/view/home/home_view.dart';
import 'package:udaadaa/view/mypage/mypage_view.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      const _NavigatorPage(child: HomeView()),
      const _NavigatorPage(child: FeedView()),
      const _NavigatorPage(child: MyPageView()),
    ];
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        child: BlocBuilder<BottomNavCubit, BottomNavState>(
            builder: (context, state) {
          return IndexedStack(
            index: BottomNavState.values.indexOf(state),
            children: children,
          );
        }),
      ),
      bottomNavigationBar: BlocBuilder<BottomNavCubit, BottomNavState>(
        builder: (context, state) => BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.feed_rounded),
              label: '피드',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: '마이페이지',
            ),
          ],
          currentIndex: BottomNavState.values.indexOf(state),
          selectedItemColor: Theme.of(context).primaryColor,
          onTap: (index) {
            context
                .read<BottomNavCubit>()
                .selectTab(BottomNavState.values[index]);
          },
        ),
      ),
    );
  }
}

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
