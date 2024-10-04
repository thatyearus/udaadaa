import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/bottom_nav_cubit.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/feed/feed_view.dart';
import 'package:udaadaa/view/home/home_view.dart';
import 'package:udaadaa/view/mypage/mypage_view.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/view/onboarding/first_view.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      const _NavigatorPage(child: HomeView()),
      const _NavigatorPage(child: FeedView()),
      const _NavigatorPage(child: MyPageView()),
    ];
    final List<String> labels = ['홈', '피드', '마이페이지'];

    return Scaffold(
      body: SafeArea(
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
          onTap: (index) {
            Analytics().logEvent(
              "네비게이션바",
              parameters: {"클릭": labels[index]},
            );
            context
                .read<BottomNavCubit>()
                .selectTab(BottomNavState.values[index]);
          },
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        width: double.infinity,
        child: FloatingActionButton.extended(
          heroTag: 'addFood',
          onPressed: () {
            Analytics().logEvent("홈_공감받으러가기");
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const FirstView(),
              ),
            );
          },
          label: Text(
            '반응 받으러 가기',
            style: AppTextStyles.textTheme.headlineLarge,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
