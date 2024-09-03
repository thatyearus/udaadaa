import 'package:flutter/material.dart';
import 'package:udaadaa/widgets/fab.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text('Home'),
      floatingActionButton: AddFabButton(),
    );
  }
}
