import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/bottom_nav_cubit.dart';
import 'package:udaadaa/models/notification_type.dart';
import 'package:udaadaa/service/shared_preferences.dart';

import 'package:udaadaa/view/main_view.dart';
import 'package:udaadaa/view/newonboarding/initial_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  SplashViewState createState() => SplashViewState();
}

class SplashViewState extends State<SplashView> {
  String messageType = "🔄 일반 진입 중..."; // 👉 디버깅용 텍스트 상태
  @override
  void initState() {
    super.initState();
    _checkInitialMessage();
    context.read<AuthCubit>();
    context.read<BottomNavCubit>();
    // _checkOnboardingStatus();
  }

  void _checkInitialMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (!mounted) return;

    final data = initialMessage?.data ?? {};
    final roomId = data['roomId'];
    final feedId = data['feedId'];

    if (roomId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainView(
              notificationType: NotificationType.message,
              id: roomId,
            ),
          ),
        );
      });
      return;
    }

    if (feedId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainView(
              notificationType: NotificationType.feed,
              id: feedId,
            ),
          ),
        );
      });
      return;
    }

    checkOnboardingStatus();
  }

  void checkOnboardingStatus() {
    bool isOnboardingComplete =
        PreferencesService().getBool('isOnboardingComplete') ?? false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              isOnboardingComplete ? const MainView() : const InitialView(),
        ),
      );
    });
    return;
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
