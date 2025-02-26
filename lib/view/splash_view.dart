import 'package:flutter/material.dart';
import 'package:udaadaa/view/main_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  SplashViewState createState() => SplashViewState();
}

class SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  void _checkOnboardingStatus() {
    /*bool isOnboardingComplete =
        PreferencesService().getBool('isOnboardingComplete') ?? false;
    bool isMealCompleted =
        PreferencesService().getBool('isMealCompleted') ?? false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isOnboardingComplete) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainView()),
        );
      } else if (isMealCompleted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const EighthView()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const InitialView()),
        );
      }
    });*/
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainView()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
