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

class _MainViewState extends State<MainView> {
  bool _notificationHandled = false;

  // 메시지알람, 피드알람, 일반 분기처리
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_notificationHandled) return;
    _notificationHandled = true;

    if (widget.notificationType == NotificationType.message &&
        widget.id != null) {
      _waitAndEnterRoom(widget.id!);
    }

    if (widget.notificationType == NotificationType.feed && widget.id != null) {
      context.read<BottomNavCubit>().selectTab(BottomNavState.feed);
      // 필요시 Feed 열기 처리 추가
    }
  }

  void _waitAndEnterRoom(String roomId) async {
    const maxRetries = 10;
    const delay = Duration(milliseconds: 300);

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      final chatCubit = context.read<ChatCubit>(); // ✅ 최신 상태로 매번 가져오기
      final room = chatCubit.getChatList
          .where((r) => r.id == roomId)
          .cast<Room?>()
          .firstOrNull;

      if (room != null) {
        if (!mounted) return;

        context.read<BottomNavCubit>().selectTab(BottomNavState.chat);

        chatCubit.enterRoom(roomId);

        Analytics().logEvent('채팅방_입장', parameters: {'room_id': room.id});

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              settings: const RouteSettings(name: 'ChatView'),
              builder: (context) => ChatView(roomInfo: room),
            ),
          );
        });
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
          content: Text('채팅방 정보를 불러오지 못했어요 🥲'),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      action: SnackBarAction(
                        label: '바로가기 >',
                        textColor: Colors.yellow,
                        onPressed: () {
                          context.read<FeedCubit>().openFeed(state.feedId);
                        },
                      ),
                      content: Text(state.text),
                    ),
                  );
                }
              },
              child: BlocListener<ChatCubit, ChatState>(
                listener: (context, state) {
                  if (state is ChatPushOpenedFromBackground) {
                    // final currentTab = context.read<BottomNavCubit>().state;

                    // 직접 onPressed 로직 실행 (SnackBar 없이)
                    context
                        .read<BottomNavCubit>()
                        .selectTab(BottomNavState.chat);
                    context.read<ChatCubit>().enterRoom(state.roomId);

                    // 채팅방으로 바로 이동
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatView(
                          roomInfo: state.roomInfo,
                        ),
                      ),
                    );
                  }
                },
                child: IndexedStack(
                  index: BottomNavState.values.indexOf(state),
                  children: children,
                ),
              ));
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
