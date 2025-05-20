import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/bottom_nav_cubit.dart';
import 'package:udaadaa/models/notification_type.dart';
import 'package:udaadaa/service/shared_preferences.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

import 'package:udaadaa/view/main_view.dart';
import 'package:udaadaa/view/newonboarding/initial_view.dart';
import 'package:udaadaa/view/newonboarding/onboarding_login_view.dart';
import 'package:udaadaa/view/newonboarding/profile_onboarding_view.dart';

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
    // _checkInitialMessage();
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

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(
    //       builder: (context) => const MainView(),
    //     ),
    //   );
    // });
    checkOnboardingStatus();
  }

  void checkOnboardingStatus() {
    bool isNewOnboardingComplete =
        PreferencesService().getBool('isNewOnboardingComplete') ?? false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => isNewOnboardingComplete
              ? const MainView()
              : const ProfileOnboardingView(),
        ),
      );
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          final provider = supabase.auth.currentUser?.appMetadata['provider'];
          if (provider == 'kakao' || provider == 'apple') {
            _checkInitialMessage();
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const OnboardingLoginView(),
                ),
              );
            });
          }
        }
      },
      child: const Scaffold(
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
