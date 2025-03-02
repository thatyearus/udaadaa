import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:badges/badges.dart' as badges;
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/cubit/tutorial_cubit.dart';
import 'package:udaadaa/models/room.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/chat/chat_view.dart';

class RoomView extends StatelessWidget {
  const RoomView({super.key});

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final isToday = now.year == timestamp.year &&
        now.month == timestamp.month &&
        now.day == timestamp.day;

    if (isToday) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.month.toString().padLeft(2, '0')}월 ${timestamp.day.toString().padLeft(2, '0')}일';
    }
  }

  void showTutorial(BuildContext context) {
    final onboardingCubit = context.read<TutorialCubit>();

    TutorialCoachMark tutorialCoachMark = TutorialCoachMark(
      hideSkip: true,
      targets: [
        TargetFocus(
          identify: "first_room",
          keyTarget: onboardingCubit.chatRoomKey,
          shape: ShapeLightFocus.RRect,
          radius: 8,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              child: Container(
                padding: AppSpacing.edgeInsetsS,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "채팅방에 입장해볼까요?",
                  style: AppTextStyles.textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ],
      onClickTarget: (target) {
        logger.d("onClickTarget: ${target.identify}");
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: onboardingCubit,
              child: ChatView(
                roomInfo: context.read<ChatCubit>().getChatList.first,
              ),
            ),
          ),
        );
        context
            .read<ChatCubit>()
            .enterRoom(context.read<ChatCubit>().getChatList.first.id);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            context.read<TutorialCubit>().showTutorialChat();
          }
        });
      },
      onFinish: () {
        logger.d("finish tutorial room view");
        // context.read<TutorialCubit>().showTutorialChat();
      },
    );

    tutorialCoachMark.show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    List<Room> rooms = context.select((ChatCubit cubit) => cubit.getChatList);
    Map<String, int> unreadCount =
        context.select((ChatCubit cubit) => cubit.getUnreadMessages);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '채팅',
          style: AppTextStyles.textTheme.headlineLarge,
        ),
        centerTitle: false,
        surfaceTintColor: AppColors.white,
      ),
      body: BlocListener<TutorialCubit, TutorialState>(
        listener: (context, state) {
          if (state is TutorialRoom && rooms.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (context.mounted) {
                  showTutorial(context);
                }
              });
            });
          }
        },
        child: ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            return ListTile(
              key: (index == 0
                  ? context.read<TutorialCubit>().chatRoomKey
                  : null),
              title: Text(rooms[index].roomName),
              subtitle: Text(rooms[index].lastMessage?.content ??
                  (rooms[index].lastMessage?.imagePath != null ? '사진' : '')),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    rooms[index].lastMessage != null
                        ? _formatTimestamp(rooms[index].lastMessage?.createdAt)
                        : '',
                    style: AppTextStyles.labelSmall(
                      TextStyle(color: AppColors.neutral[500]),
                    ),
                  ),
                  if (unreadCount[rooms[index].id] != null &&
                      unreadCount[rooms[index].id]! > 0)
                    badges.Badge(
                      badgeContent: Text(
                        unreadCount[rooms[index].id].toString(),
                        style: AppTextStyles.labelSmall(
                          const TextStyle(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<TutorialCubit>(),
                      child: ChatView(
                        roomInfo: rooms[index],
                      ),
                    ),
                  ),
                );
                context.read<ChatCubit>().enterRoom(rooms[index].id);
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (context.mounted) {
                    context.read<TutorialCubit>().showTutorialChat();
                  }
                });
              },
            );
          },
        ),
      ),
    );
  }
}
