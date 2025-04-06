import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:badges/badges.dart' as badges;
import 'package:udaadaa/cubit/bottom_nav_cubit.dart';
import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/models/notification_type.dart';
import 'package:udaadaa/models/room.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/chat/chat_view.dart';
import 'package:udaadaa/view/chat/room_view.dart';
import 'package:udaadaa/view/detail/my_record_view.dart';
import 'package:udaadaa/view/feed/feed_view.dart';
import 'package:udaadaa/view/home/home_view.dart';
import 'package:udaadaa/view/mypage/mypage_view.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/view/register/register_view.dart';

class MainView extends StatefulWidget {
  final NotificationType? notificationType;
  final String? id;

  const MainView({super.key, this.notificationType, this.id});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> with WidgetsBindingObserver {
  bool _notificationHandled = false;
  late OverlayEntry overlayEntry;
  bool isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ✅ 생명주기 감지 등록
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ✅ 등록 해제
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ✅ 백 → 포그라운드 전환 시 처리
    if (state == AppLifecycleState.resumed) {
      final chatCubit = context.read<ChatCubit>();

      if (!chatCubit.wasPushHandled) {
        debugPrint("🌅 백그라운드 → 포그라운드: 메시지 수동 새로고침 시도");
        chatCubit.refreshAllMessagesForPush(); // 새로운 메시지 갱신 (리팩터된 함수 사용)
      } else {
        debugPrint("🚫 푸시 알람클릭 푸시알람에서 처리하겠음.");
        chatCubit.wasPushHandled = false;
      }
    }
  }

  // 꺼져있을때 메시지알람, 피드알람, 일반 분기처리
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_notificationHandled) return;
    _notificationHandled = true;

    if (widget.notificationType == NotificationType.message &&
        widget.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        waitAndEnterRoom(widget.id!); // ✅ build 후 안전하게 실행됨
      });
    }

    if (widget.notificationType == NotificationType.feed && widget.id != null) {
      context.read<BottomNavCubit>().selectTab(BottomNavState.feed);
      // 필요시 Feed 열기 처리 추가
    }
  }

  Future<void> waitAndEnterRoom(String roomId) async {
    debugPrint("🔍 waitAndEnterRoom 시작: roomId=$roomId");

    // ✅ 1. 다이얼로그 띄우기 (뒤로가기 막기)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    const maxRetries = 15;
    const delay = Duration(milliseconds: 400);

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      if (!mounted) return;
      final chatCubit = context.read<ChatCubit>();

      // 1️⃣ ChatCubit 초기화 상태 체크
      if (!chatCubit.isInitialized) {
        debugPrint("⏳ ChatCubit 초기화 대기 중... (시도 #$attempt)");
        await Future.delayed(delay);
        continue;
      }

      debugPrint("🔄 시도 #$attempt - 채팅방 찾는 중...");

      final room = chatCubit.getChatList
          .where((r) => r.id == roomId)
          .cast<Room?>()
          .firstOrNull;

      if (room != null) {
        debugPrint("✅ 채팅방 찾음! roomId=$roomId, 제목=${room.roomName}");

        if (!mounted) return;

        context.read<BottomNavCubit>().selectTab(BottomNavState.chat);
        Analytics().logEvent('채팅방_입장', parameters: {'room_id': room.id});

        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop(); // ✅ 2. 다이얼로그 닫기
        Navigator.of(context).push(
          MaterialPageRoute(
            settings: const RouteSettings(name: 'ChatView'),
            builder: (context) => ChatView(roomInfo: room),
          ),
        );

        await chatCubit.enterRoom1(roomId);
        debugPrint("✅ enterRoom1 완료!");

        return;
      }

      await Future.delayed(delay);
    }

    if (!mounted) return;

    debugPrint("❌ roomId=$roomId 에 해당하는 채팅방을 찾지 못함");

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (!mounted) return;
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('채팅방 정보를 불러오지 못했어요 🥲 다시 앱을 실행시켜주세요'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      /*
      const _NavigatorPage(child: HomeView()),
      const _NavigatorPage(child: FeedView()),
      const _NavigatorPage(child: MyPageView()),*/
      const HomeView(),
      const RoomView(),
      const RegisterView(),
      const FeedView(),
      const MyPageView(),
    ];
    final List<String> labels = ['홈', '채팅', '신청', '피드', '마이페이지'];

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<BottomNavCubit, BottomNavState>(
            builder: (context, state) {
          return BlocListener<FeedCubit, FeedState>(
            listener: (context, state) {
              if (state is FeedDetail) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MyRecordView(
                      initialPage: state.index,
                    ),
                  ),
                );
              }
              if (state is FeedPushNotification) {
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     action: SnackBarAction(
                //       label: '바로가기 >',
                //       textColor: Colors.yellow,
                //       onPressed: () {
                //         context.read<FeedCubit>().openFeed(state.feedId);
                //       },
                //     ),
                //     content: Text(state.text),
                //   ),
                // );
              }
            },
            child: BlocListener<ChatCubit, ChatState>(
              listener: (context, state) {
                if (state is ChatPushStarted) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is ChatPushOpenedFromBackground) {
                  Navigator.of(context, rootNavigator: true).pop();
                  final chatCubit = context.read<ChatCubit>();

                  context.read<BottomNavCubit>().selectTab(BottomNavState.chat);
                  // 채팅방으로 바로 이동

                  // 현재 방과 동일한 경우 enterRoom 생략
                  if (chatCubit.currentRoomId != state.roomId) {
                    context
                        .read<BottomNavCubit>()
                        .selectTab(BottomNavState.chat);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        settings: const RouteSettings(name: 'ChatView'),
                        builder: (context) => ChatView(
                          roomInfo: state.roomInfo,
                        ),
                      ),
                    );
                  } else {
                    debugPrint("✅ 이미 채팅방에 들어가 있음, enterRoom 생략");
                  }
                  chatCubit.enterRoom1(state.roomId); // 👉 여기 조건문 안에 있으니까 안전
                }
              },
              child: IndexedStack(
                index: BottomNavState.values.indexOf(state),
                children: children,
              ),
            ),
          );
        }),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BlocBuilder<BottomNavCubit, BottomNavState>(
            builder: (context, state) {
          final unreadMessagesCount = context.select<ChatCubit, int>(
            (cubit) => cubit.getUnreadMessageCount,
          );
          return BottomNavigationBar(
            selectedItemColor: AppColors.neutral[800],
            unselectedItemColor: AppColors.neutral[400],
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              const BottomNavigationBarItem(
                icon: Icon(FluentIcons.home_24_regular),
                activeIcon: Icon(FluentIcons.home_24_filled),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: badges.Badge(
                  showBadge: unreadMessagesCount > 0,
                  badgeContent: Text(
                    unreadMessagesCount.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  child: const Icon(FluentIcons.chat_multiple_24_regular),
                ),
                activeIcon: badges.Badge(
                  showBadge: unreadMessagesCount > 0,
                  badgeContent: Text(
                    unreadMessagesCount.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  child: const Icon(FluentIcons.chat_multiple_24_filled),
                ),
                label: '채팅',
              ),
              const BottomNavigationBarItem(
                icon: Icon(FluentIcons.add_square_24_regular),
                activeIcon: Icon(FluentIcons.add_square_24_filled),
                label: '신청',
              ),
              const BottomNavigationBarItem(
                icon: Icon(FluentIcons.channel_24_regular),
                activeIcon: Icon(FluentIcons.channel_24_filled),
                label: '피드',
              ),
              const BottomNavigationBarItem(
                icon: Icon(FluentIcons.person_24_regular),
                activeIcon: Icon(FluentIcons.person_24_filled),
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
          );
        }),
      ),
    );
  }
}
