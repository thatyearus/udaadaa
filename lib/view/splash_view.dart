import 'package:flutter/material.dart';
import 'package:udaadaa/service/shared_preferences.dart';
import 'package:udaadaa/view/main_view.dart';
import 'package:udaadaa/view/onboarding/initial_view.dart';

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
    bool isOnboardingComplete =
        PreferencesService().getBool('isOnboardingComplete') ?? false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isOnboardingComplete) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainView()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const InitialView()),
        );
      }
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
