import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/models/notification_type.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/chat/chat_view.dart';

import 'package:udaadaa/view/main_view.dart';

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
