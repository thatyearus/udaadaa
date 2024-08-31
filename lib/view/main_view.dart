import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/bottom_nav_cubit.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      const Text('Home'),
      const Text('Feed'),
      const Text('Profile'),
    ];
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(8),
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
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.surfing),
              label: 'Feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: BottomNavState.values.indexOf(state),
          selectedItemColor: Colors.blue,
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
