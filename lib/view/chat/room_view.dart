import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:badges/badges.dart' as badges;
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/cubit/tutorial_cubit.dart';
import 'package:udaadaa/models/room.dart';
import 'package:udaadaa/service/shared_preferences.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
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
      hideSkip: false,
      onSkip: () {
        logger.d("스킵 누름 - room_view");
        Analytics().logEvent("튜토리얼_스킵", parameters: {
          "view": "room_view", // 현재 튜토리얼이 실행된 뷰
        });
        PreferencesService().setBool('isTutorialFinished', true);
        return true; // 👈 튜토리얼 종료
      },
      alignSkip: Alignment.topLeft,
      skipWidget: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: const Text(
          "SKIP",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      targets: [
        TargetFocus(
          identify: "first_room",
          keyTarget: onboardingCubit.chatRoomKey,
          shape: ShapeLightFocus.RRect,
          radius: 8,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              child: Text(
                "채팅방에 입장해볼까요?",
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  color: Colors.white, // 흰색 글씨
                  fontWeight: FontWeight.bold, // 글씨 굵게 (Bold)
                  fontSize: 18, // 글씨 크기 증가
                ),
              ),
            ),
          ],
        ),
      ],
      onClickTarget: (target) {
        Analytics().logEvent('튜토리얼_채팅방1',
            parameters: {'target': target.identify.toString()});
        logger.d("onClickTarget: ${target.identify}");
        Navigator.of(context).push(
          MaterialPageRoute(
            settings: RouteSettings(name: 'ChatView'),
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

  // void showTutorial2(BuildContext context) {
  //   final onboardingCubit = context.read<TutorialCubit>();

  //   TutorialCoachMark tutorialCoachMark = TutorialCoachMark(
  //     hideSkip: true,
  //     targets: [
  //       TargetFocus(
  //         identify: "first_room",
  //         keyTarget: onboardingCubit.chatRoomKey,
  //         shape: ShapeLightFocus.RRect,
  //         radius: 8,
  //         contents: [
  //           TargetContent(
  //             align: ContentAlign.bottom,
  //             child: Container(
  //               padding: AppSpacing.edgeInsetsS,
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: Text(
  //                 "빠른 시일 내에 1:1 문의방이 자동으로 생성될 예정입니다.",
  //                 style: AppTextStyles.textTheme.bodyMedium,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //     onClickTarget: (target) {
  //       Analytics().logEvent('튜토리얼_채팅방2',
  //           parameters: {'target': target.identify.toString()});
  //       logger.d("onClickTarget: ${target.identify}");

  //       Future.delayed(const Duration(milliseconds: 500), () {
  //         if (context.mounted) {
  //           context.read<BottomNavCubit>().selectTab(BottomNavState.profile);
  //           context.read<TutorialCubit>().showTutorialProfile();
  //         }
  //       });
  //     },
  //     onClickOverlay: (target) {
  //       logger.d("onClickOverlay: ${target.identify}");
  //       Future.delayed(const Duration(milliseconds: 500), () {
  //         if (context.mounted) {
  //           context.read<BottomNavCubit>().selectTab(BottomNavState.profile);
  //           context.read<TutorialCubit>().showTutorialProfile();
  //         }
  //       });
  //     },
  //     onFinish: () {
  //       logger.d("finish tutorial room view2");
  //       // context.read<TutorialCubit>().showTutorialChat();
  //     },
  //   );

  //   tutorialCoachMark.show(context: context);
  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      buildWhen: (previous, current) =>
          current is ChatMessageLoaded || current is UnreadMessagesUpdated,
      builder: (context, state) {
        List<Room> rooms = context.read<ChatCubit>().getChatList;
        Map<String, int> unreadCount =
            context.read<ChatCubit>().getUnreadMessages;

        debugPrint("[DEBUG] 현재 unreadCount 상태: $unreadCount");

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
                    if (context.mounted &&
                        PreferencesService().getBool('isTutorialFinished') !=
                            true) {
                      showTutorial(context);
                    }
                  });
                });
              }
              // else if (state is TutorialRoom2 && rooms.isNotEmpty) {
              //   WidgetsBinding.instance.addPostFrameCallback((_) {
              //     Future.delayed(const Duration(milliseconds: 1000), () {
              //       if (context.mounted &&
              //           PreferencesService().getBool('isTutorialFinished') !=
              //               true) {
              //         // showTutorial2(context);
              //       }
              //     });
              //   });
              // }
            },
            child: ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                final unread = unreadCount[room.id] ?? 0;

                return ListTile(
                  key: (index == 0
                      ? context.read<TutorialCubit>().chatRoomKey
                      : null),
                  title: Text(room.roomName),
                  subtitle: Text(room.lastMessage?.content ??
                      (room.lastMessage?.imagePath != null ? '사진' : '')),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        room.lastMessage != null
                            ? _formatTimestamp(room.lastMessage?.createdAt)
                            : '',
                        style: AppTextStyles.labelSmall(
                          TextStyle(color: AppColors.neutral[500]),
                        ),
                      ),
                      if (unread > 0)
                        badges.Badge(
                          badgeContent: Text(
                            unread.toString(),
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
                    Analytics()
                        .logEvent('채팅방_입장', parameters: {'room_id': room.id});
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        settings: RouteSettings(name: 'ChatView'),
                        builder: (context) => BlocProvider.value(
                          value: context.read<TutorialCubit>(),
                          child: ChatView(
                            roomInfo: room,
                          ),
                        ),
                      ),
                    );
                    context.read<ChatCubit>().enterRoom(room.id);
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
      },
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   List<Room> rooms = context.select((ChatCubit cubit) => cubit.getChatList);
  //   Map<String, int> unreadCount =
  //       context.select((ChatCubit cubit) => cubit.getUnreadMessages);

  //   debugPrint("[DEBUG] 현재 unreadCount 상태: $unreadCount");
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(
  //         '채팅',
  //         style: AppTextStyles.textTheme.headlineLarge,
  //       ),
  //       centerTitle: false,
  //       surfaceTintColor: AppColors.white,
  //     ),
  //     body: BlocListener<TutorialCubit, TutorialState>(
  //       listener: (context, state) {
  //         if (state is TutorialRoom && rooms.isNotEmpty) {
  //           WidgetsBinding.instance.addPostFrameCallback((_) {
  //             Future.delayed(const Duration(milliseconds: 1000), () {
  //               if (context.mounted &&
  //                   PreferencesService().getBool('isTutorialFinished') !=
  //                       true) {
  //                 showTutorial(context);
  //               }
  //             });
  //           });
  //         } else if (state is TutorialRoom2 && rooms.isNotEmpty) {
  //           WidgetsBinding.instance.addPostFrameCallback((_) {
  //             Future.delayed(const Duration(milliseconds: 1000), () {
  //               if (context.mounted &&
  //                   PreferencesService().getBool('isTutorialFinished') !=
  //                       true) {
  //                 showTutorial2(context);
  //               }
  //             });
  //           });
  //         }
  //       },
  //       child: ListView.builder(
  //         itemCount: rooms.length,
  //         itemBuilder: (context, index) {
  //           return ListTile(
  //             key: (index == 0
  //                 ? context.read<TutorialCubit>().chatRoomKey
  //                 : null),
  //             title: Text(rooms[index].roomName),
  //             subtitle: Text(rooms[index].lastMessage?.content ??
  //                 (rooms[index].lastMessage?.imagePath != null ? '사진' : '')),
  //             trailing: Column(
  //               crossAxisAlignment: CrossAxisAlignment.end,
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Text(
  //                   rooms[index].lastMessage != null
  //                       ? _formatTimestamp(rooms[index].lastMessage?.createdAt)
  //                       : '',
  //                   style: AppTextStyles.labelSmall(
  //                     TextStyle(color: AppColors.neutral[500]),
  //                   ),
  //                 ),
  //                 if (unreadCount[rooms[index].id] != null &&
  //                     unreadCount[rooms[index].id]! > 0)
  //                   badges.Badge(
  //                     badgeContent: Text(
  //                       unreadCount[rooms[index].id].toString(),
  //                       style: AppTextStyles.labelSmall(
  //                         const TextStyle(
  //                           color: AppColors.white,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //               ],
  //             ),
  //             onTap: () {
  //               Analytics().logEvent('채팅방_입장',
  //                   parameters: {'room_id': rooms[index].id});
  //               Navigator.of(context).push(
  //                 MaterialPageRoute(
  //                   settings: RouteSettings(name: 'ChatView'),
  //                   builder: (context) => BlocProvider.value(
  //                     value: context.read<TutorialCubit>(),
  //                     child: ChatView(
  //                       roomInfo: rooms[index],
  //                     ),
  //                   ),
  //                 ),
  //               );
  //               context.read<ChatCubit>().enterRoom(rooms[index].id);
  //               Future.delayed(const Duration(milliseconds: 500), () {
  //                 if (context.mounted) {
  //                   context.read<TutorialCubit>().showTutorialChat();
  //                 }
  //               });
  //             },
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }
}
