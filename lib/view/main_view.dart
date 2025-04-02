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
  final List<_NotificationData> _notificationQueue = [];
  bool _isNotificationShowing = false;

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
        debugPrint("🚫 푸시 처리로 인해 자동 새로고침은 스킵됨");
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
      waitAndEnterRoom(widget.id!);
    }

    if (widget.notificationType == NotificationType.feed && widget.id != null) {
      context.read<BottomNavCubit>().selectTab(BottomNavState.feed);
      // 필요시 Feed 열기 처리 추가
    }
  }

  void showTopAnimatedNotification(BuildContext context,
      {required String title, required String body, required String roomId}) {
    _notificationQueue.add(_NotificationData(title, body, roomId));
    _showNextNotification(context);
  }

  void _showNextNotification(BuildContext context) async {
    if (_isNotificationShowing || _notificationQueue.isEmpty) return;

    _isNotificationShowing = true;
    final notification = _notificationQueue.removeAt(0);
    final overlay = Overlay.of(context);
    final animationController = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 200),
    );

    final animation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutBack,
    ));

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: SlideTransition(
          position: animation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                animationController.stop();
                entry.remove();
                animationController.dispose();
                waitAndEnterRoom(notification.roomId);
                _isNotificationShowing = false;
                _notificationQueue.clear(); // 🧹 알림 큐 싹 비우기
                _showNextNotification(context); // 다음 알림 띄우기
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notification.title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(notification.body,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    animationController.forward();

    await Future.delayed(const Duration(milliseconds: 1200));

    try {
      if (animationController.status == AnimationStatus.forward ||
          animationController.status == AnimationStatus.completed) {
        await animationController.reverse();
      }
      entry.remove();
      animationController.dispose();
    } catch (_) {}

    _isNotificationShowing = false;
    _showNextNotification(context); // 다음 알림 띄우기
  }

  Future<void> waitAndEnterRoom(String roomId) async {
    // ✅ setReadReceiptListener와 messages 초기화 기다리기 위함
    await Future.delayed(const Duration(milliseconds: 300));

    const maxRetries = 10;
    const delay = Duration(milliseconds: 300);

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      if (!mounted) return;
      final chatCubit = context.read<ChatCubit>(); // ✅ 최신 상태로 매번 가져오기
      final room = chatCubit.getChatList
          .where((r) => r.id == roomId)
          .cast<Room?>()
          .firstOrNull;

      if (room != null) {
        debugPrint("✅ room 찾음! enterRoom 호출 시작");

        if (!mounted) return;

        context.read<BottomNavCubit>().selectTab(BottomNavState.chat);
        Analytics().logEvent('채팅방_입장', parameters: {'room_id': room.id});

        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            settings: const RouteSettings(name: 'ChatView'),
            builder: (context) => ChatView(roomInfo: room),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 700));
        await chatCubit.enterRoom(roomId);

        return;
      }

      await Future.delayed(delay);
      if (!mounted) return;
    }

    if (!mounted) return;

    debugPrint("❗roomId=$roomId 에 해당하는 채팅방을 끝내 못 찾음");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('채팅방 정보를 불러오지 못했어요 🥲 다시 앱을 실행시켜주세요'),
          backgroundColor: Colors.red,
        ),
      );
    });
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
                if (state is ChatNotificationReceivedInForeground) {
                  final body = state.body;
                  final title = state.roomInfo.roomName;
                  final roomId = state.roomInfo.id;

                  final currentRoomId = context.read<ChatCubit>().currentRoomId;

                  if (currentRoomId != roomId) {
                    showTopAnimatedNotification(context,
                        title: title, body: body, roomId: roomId);
                  } else {
                    logger.d("🔕 알림 스킵: 현재 방과 동일 ($roomId)");
                  }
                }

                if (state is ChatPushOpenedFromBackground) {
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
                        builder: (context) => ChatView(
                          roomInfo: state.roomInfo,
                        ),
                      ),
                    );
                  } else {
                    debugPrint("✅ 이미 채팅방에 들어가 있음, enterRoom 생략");
                  }
                  chatCubit.enterRoom(state.roomId); // 👉 여기 조건문 안에 있으니까 안전
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => ChatView(
                  //       roomInfo: state.roomInfo,
                  //     ),
                  //   ),
                  // );
                  // context.read<ChatCubit>().enterRoom(state.roomId);
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

class _NotificationData {
  final String title;
  final String body;
  final String roomId;

  _NotificationData(this.title, this.body, this.roomId);
}
