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

    if (initialMessage != null) {
      final data = initialMessage.data;
      final roomId = data['roomId'];
      final feedId = data['feedId'];

      // roomId가 null이 아니면 room 알림 처리
      if (roomId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainView(
                notificationType: NotificationType.message, // room 알림
                id: roomId, // roomId 전달
              ),
            ),
          );
        });
        return; // roomId가 있으면 바로 처리하고 종료
      }

      // feedId가 null이 아니면 feed 알림 처리
      if (feedId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainView(
                notificationType: NotificationType.feed, // feed 알림
                id: feedId, // feedId 전달
              ),
            ),
          );
        });
        return; // feedId가 있으면 바로 처리하고 종료
      }

      // roomId와 feedId가 둘 다 null이면 기본 화면만 띄움
      checkOnboardingStatus();
    } else {
      // 푸시 알림이 없으면 기본 화면만 띄움
      checkOnboardingStatus();
    }
  }

  // Future<void> tryOpenChatRoom(BuildContext context, String roomId) async {
  //   final navigator = Navigator.of(context);
  //   final cubit = context.read<ChatCubit>();

  //   int retry = 0;
  //   while (!cubit.isInitialized) {
  //     await Future.delayed(const Duration(milliseconds: 100));
  //     retry++;
  //     if (retry > 15) {
  //       logger.d("⛔ ChatCubit 초기화 타임아웃. 그냥 넘어감");
  //       checkOnboardingStatus();
  //       return;
  //     }
  //   }

  //   try {
  //     final room = cubit.getRoom(roomId);
  //     cubit.enterRoom(roomId);

  //     navigator.pushReplacement(MaterialPageRoute(
  //       builder: (_) => ChatView(roomInfo: room, fromPush: true),
  //     ));
  //   } catch (e) {
  //     debugPrint("해당 roomId에 대한 방 정보 없음");
  //   }
  // }

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
