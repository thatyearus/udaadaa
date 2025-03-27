import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/bottom_nav_cubit.dart';

import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/cubit/form_cubit.dart';
import 'package:udaadaa/cubit/tutorial_cubit.dart';
import 'package:udaadaa/models/message.dart';
import 'package:udaadaa/models/room.dart';
import 'package:udaadaa/service/shared_preferences.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/chat/image_detail_view.dart';
import 'package:udaadaa/view/chat/image_list_view.dart';
import 'package:udaadaa/view/chat/profile_view.dart';
import 'package:udaadaa/view/chat/ranking_view.dart';
import 'package:udaadaa/view/form/exercise/exercise_first_view.dart';
import 'package:udaadaa/view/form/weight/weight_first_view.dart';
import 'package:udaadaa/view/onboarding/first_view.dart';
import 'package:udaadaa/widgets/chat_bubble.dart';

/// Page to chat with someone.
///
/// Displays chat bubbles as a ListView and TextField to enter new chat.
class ChatView extends StatelessWidget {
  const ChatView({super.key, required this.roomInfo});

  /*static Route<void> route(String roomId) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider<ChatCubit>(
        create: (context) => ChatCubit()..setMessagesListener(roomId),
        child: const ChatPage(),
      ),
    );
  }*/
  final Room roomInfo;

  void showTutorial(BuildContext context) {
    final onboardingCubit = context.read<TutorialCubit>();

    late TutorialCoachMark tutorialCoachMark;
    tutorialCoachMark = TutorialCoachMark(
      hideSkip: false,
      onSkip: () {
        logger.d("스킵 누름 - chat_view");
        Analytics().logEvent("튜토리얼_스킵", parameters: {
          "view": "chat_view", // 현재 튜토리얼이 실행된 뷰
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
      showSkipInLastTarget: false,
      targets: [
        TargetFocus(
          identify: "plus_button",
          keyTarget: onboardingCubit.chatButtonKey,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              child: Text(
                "인증을 하기 위해선 이 버튼을 눌러주세요",
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  color: Colors.white, // 흰색 글씨
                  fontWeight: FontWeight.bold, // 글씨 굵게 (Bold)
                  fontSize: 18, // 글씨 크기 증가
                ),
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: "plus_detail_button",
          keyTarget: onboardingCubit.chatButtonDetailKey,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              child: Text(
                "식단, 운동 및 체중을 인증할 수 있습니다.",
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: "menu_detail_button",
          keyTarget: onboardingCubit.chatMenuButtonKey,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              child: Text(
                "메뉴 버튼을 눌러 사진 및 참여자 목록을 확인할 수 있습니다.",
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: "push_button",
          keyTarget: onboardingCubit.pushButtonKey,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              child: Text(
                "아이콘을 눌러 푸시 알림 설정을 변경할 수도 있습니다.",
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ],
      onClickTarget: (target) {
        Analytics().logEvent('튜토리얼_채팅',
            parameters: {'target': target.identify.toString()});
        logger.d("onClickTarget: ${target.identify}");
        if (target.identify == "plus_button") {
          _showBottomSheet(context);
          Future.delayed(const Duration(milliseconds: 1000), () {
            tutorialCoachMark.next();
          });
        } else if (target.identify == "plus_detail_button") {
          Navigator.of(context).pop();
          Future.delayed(const Duration(milliseconds: 1000), () {
            tutorialCoachMark.next();
          });
        } else if (target.identify == "menu_detail_button") {
          Scaffold.of(context).openEndDrawer();
          Future.delayed(const Duration(milliseconds: 1000), () {
            tutorialCoachMark.next();
          });
        } else if (target.identify == "push_button") {
          context.read<AuthCubit>().setFCMToken();
          Navigator.of(context).pop();
        }
      },
      onFinish: () {
        logger.d("finish tutorial chat view");
        Navigator.of(context).pop();

        context.read<BottomNavCubit>().selectTab(BottomNavState.profile);
        context.read<TutorialCubit>().showTutorialProfile();

        // context.read<TutorialCubit>().showTutorialRoom2();
        /* 
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!context.mounted) return;
          context.read<TutorialCubit>().showTutorialRoom2();
        });*/
      },
    );

    tutorialCoachMark.show(context: context);
  }

  Drawer showDrawer(BuildContext context) {
    List<Message> imageMessages = context.select<ChatCubit, List<Message>>(
        (cubit) => cubit
            .getMessagesByRoomId(roomInfo.id)
            .where((element) => element.imageUrl != null)
            .toList());
    List<String> blockedUsers = context
        .select<ChatCubit, List<String>>((cubit) => cubit.getBlockedUsers);
    Map<String, bool> pushOptions = context
        .select<ChatCubit, Map<String, bool>>((cubit) => cubit.getPushOptions);
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            minimum: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roomInfo.roomName,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text('${roomInfo.members.length}명 참여중',
                    style: Theme.of(context).textTheme.bodyLarge),
                /*Text("채팅방 일자: ${roomInfo.createdAt}",
                    style: Theme.of(context).textTheme.bodyMedium),*/
              ],
            ),
          ),
          Divider(color: AppColors.neutral[200]),
/*
          DrawerHeader(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roomInfo.roomName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text('${roomInfo.members.length}명 참여중',
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),*/
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            title:
                Text('사진 모아보기', style: Theme.of(context).textTheme.titleSmall),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.neutral[500]),
            onTap: () {
              Analytics()
                  .logEvent('채팅_사진모아보기', parameters: {'room_id': roomInfo.id});
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ImageListView(
                    roomInfo: roomInfo,
                    imageMessages: imageMessages,
                  ),
                ),
              );
            },
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppSpacing.xxs,
            ),
            itemCount: min(imageMessages.length, 3),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ImageDetailView(
                        roomInfo: roomInfo,
                        imageMessage: imageMessages[index],
                      ),
                    ),
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: imageMessages[index].imageUrl!,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          AppSpacing.verticalSizedBoxXs,
          Divider(color: AppColors.neutral[200]),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Text('참여자 목록', style: Theme.of(context).textTheme.titleSmall),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: roomInfo.members.length,
              itemBuilder: (context, index) {
                bool isBlocked =
                    blockedUsers.contains(roomInfo.members[index].id);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (isBlocked
                        ? AppColors.neutral[200]
                        : AppColors.primary[50]),
                    child: Icon(Icons.person,
                        color: (isBlocked
                            ? AppColors.neutral[500]
                            : AppColors.primary)),
                  ),
                  title: Text(roomInfo.members[index].nickname,
                      style: Theme.of(context).textTheme.bodyMedium),
                  trailing: (roomInfo.members[index].id ==
                          supabase.auth.currentUser!.id)
                      ? Container(
                          padding: AppSpacing.edgeInsetsXs,
                          decoration: BoxDecoration(
                            color: AppColors.primary[50],
                            borderRadius: BorderRadius.circular(AppSpacing.s),
                          ),
                          child: Text(
                            "나",
                            style: AppTextStyles.bodyMedium(
                              TextStyle(color: AppColors.primary[500]),
                            ),
                          ),
                        )
                      : (isBlocked)
                          ? Container(
                              padding: AppSpacing.edgeInsetsXs,
                              decoration: BoxDecoration(
                                color: AppColors.neutral[200],
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.s),
                              ),
                              child: Text(
                                "차단됨",
                                style: AppTextStyles.bodyMedium(
                                  TextStyle(color: AppColors.neutral[500]),
                                ),
                              ),
                            )
                          : null,
                  onTap: () {
                    Analytics().logEvent('채팅_참여자프로필',
                        parameters: {'user_id': roomInfo.members[index].id});
                    navigateToProfileView(
                      context,
                      roomInfo.members[index].nickname,
                      roomInfo.members[index].id,
                    );
                  },
                );
              },
            ),
          ),
          Divider(color: AppColors.neutral[200]),
          ListTile(
            leading: (roomInfo.endDay != null)
                ? IconButton(
                    key: context.read<TutorialCubit>().rankingButtonKey,
                    icon: Icon(Icons.leaderboard_rounded,
                        color: AppColors.neutral[500]),
                    onPressed: () {
                      Analytics().logEvent('채팅_랭킹확인',
                          parameters: {'room_id': roomInfo.id});
                      context.read<ChatCubit>().fetchRoomRanking(roomInfo);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RankingView(
                            roomId: roomInfo.id,
                          ),
                        ),
                      );
                    },
                    /*onPressed: () async {
                  await SendbirdSdk().disconnect();
                  await supabase.Supabase.instance.client.auth.signOut();
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('user');
                  await prefs.remove('group_channel');
                  await prefs.remove('personal_channel');
                  await prefs.remove('entrance_code');
                  Navigator.popAndPushNamed(context, '/entrance');
                }*/
                  )
                : null,
            trailing: IconButton(
              key: context.read<TutorialCubit>().pushButtonKey,
              icon: /*Icon(_pushTriggerOption == GroupChannelPushTriggerOption.off
                  ? Icons.notifications_off
                  : Icons.notifications_active),*/

                  Icon(
                      pushOptions[roomInfo.id] == true
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: AppColors.neutral[500]),
              //  onPressed: _toogglePushOption,
              onPressed: () {
                Analytics().logEvent('채팅_푸시알림설정', parameters: {
                  'room_id': roomInfo.id,
                  'push_option': pushOptions[roomInfo.id]!.toString(),
                });
                context
                    .read<ChatCubit>()
                    .togglePushOption(roomInfo.id, !pushOptions[roomInfo.id]!);
              },
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    final missionName = ["아침", "점심", "저녁", "간식", "체중", "운동"];
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.s),
                child: Text('인증하기', style: AppTextStyles.textTheme.titleMedium),
              ),
              Divider(color: AppColors.neutral[200]),
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                  //crossAxisSpacing: 2.0,
                  // mainAxisSpacing: 2.0,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        key: (index == 0
                            ? context.read<TutorialCubit>().chatButtonDetailKey
                            : null),
                        icon: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.xs),
                                border: Border.all(
                                    color: AppColors.neutral[400]!, width: 2),
                              ),
                              child: Icon(Icons.add,
                                  color: AppColors.neutral[400], size: 40),
                            ),
                          ],
                        ),
                        onPressed: () {
                          Analytics().logEvent('채팅_인증하기',
                              parameters: {'mission': missionName[index]});
                          // context.read<ChatCubit>().sendMessage();
                          // _showBottomSheet(context);
                          // context.read<ChatCubit>().missionComplete();
                          if (index < 4) {
                            context
                                .read<FormCubit>()
                                .updateMealSelection(index);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const FirstView(),
                              ),
                            );
                          } else if (index == 4) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const WeightFirstView(),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ExerciseFirstView(),
                              ),
                            );
                          }
                        },
                      ),
                      AppSpacing.verticalSizedBoxXs,
                      Text(
                        missionName[index],
                        style: AppTextStyles.textTheme.bodyLarge,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // showTutorial(context);
    final messages = context.select<ChatCubit, List<Message>>(
        (cubit) => cubit.getMessagesByRoomId(roomInfo.id));
    final userName = context.select<AuthCubit, String>(
        (cubit) => cubit.getCurProfile?.nickname ?? "");
    final personalChannel =
        (roomInfo.endDay == null && roomInfo.startDay == null);
    final enabled = personalChannel ||
        (roomInfo.endDay!.isAfter(DateTime.now()) &&
            roomInfo.startDay!.isBefore(DateTime.now()));
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<ChatCubit>().leaveRoom(roomInfo.id);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            roomInfo.roomName,
            style: AppTextStyles.textTheme.headlineLarge,
          ),
          backgroundColor: AppColors.primary[100],
          surfaceTintColor: AppColors.primary[100],
          centerTitle: true,
          actions: [
            Builder(
              builder: (context) => IconButton(
                key: context.read<TutorialCubit>().chatMenuButtonKey,
                icon: Icon(Icons.menu_rounded, color: AppColors.neutral[800]),
                onPressed: () {
                  Analytics().logEvent('채팅_메뉴버튼클릭');
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ],
        ),
        endDrawer: showDrawer(context),
        body: BlocListener<TutorialCubit, TutorialState>(
          listener: (context, state) {
            if (state is TutorialChat) {
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
          },
          child: Column(
            children: [
              Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s, vertical: AppSpacing.xxs),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.25),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(FluentIcons.megaphone_24_regular,
                          color: AppColors.neutral[500]),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.s),
                          child: Text(
                            personalChannel
                                ? '궁금한 점이 있으시면 언제든지 이 채널로 문의해주세요.'
                                : '우측 하단의 + 버튼을 눌러 인증을 진행해 주세요.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  )),
              Expanded(
                child: DashChat(
                  currentUser:
                      asDashChatUser(supabase.auth.currentUser!.id, userName),
                  inputOptions: InputOptions(
                      inputDisabled: !enabled,
                      sendOnEnter: false,
                      textInputAction: TextInputAction.newline,
                      inputMaxLines: 2,
                      inputToolbarMargin: EdgeInsets.zero,
                      inputToolbarPadding: const EdgeInsets.all(2),
                      inputToolbarStyle:
                          BoxDecoration(color: AppColors.white, boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -4),
                        ),
                      ]),
                      inputTextStyle: Theme.of(context).textTheme.bodyMedium,
                      inputDecoration: InputDecoration(
                        isDense: true,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.m),
                          /*
                      borderSide: BorderSide(
                        color: AppColors.neutral[200]!,
                      ),*/
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.m),
                          /*
                      borderSide: BorderSide(
                        color: AppColors.neutral[200]!,
                      ),*/
                          borderSide: BorderSide.none,
                        ),
                        hintText: '메시지를 입력하세요',
                        hintStyle: AppTextStyles.bodyMedium(
                          TextStyle(color: AppColors.neutral[500]),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s,
                          vertical: AppSpacing.xs,
                        ),
                        filled: true,
                        fillColor: AppColors.neutral[50],
                      ),
                      leading: [
                        enabled
                            ? IconButton(
                                icon: Icon(Icons.photo_outlined,
                                    color: AppColors.neutral[500]),
                                onPressed: () {
                                  Analytics().logEvent('채팅_사진전송');
                                  context
                                      .read<ChatCubit>()
                                      .sendImageMessage(roomInfo.id);
                                  // final img = await context.read<ChatCubit>().pickImage();
                                  // context.read<ChatCubit>().sendFileMessage(img);
                                },
                              )
                            : Container(
                                padding: const EdgeInsets.all(2),
                              ),
                      ],
                      trailing: [
                        (!personalChannel && enabled)
                            ? IconButton(
                                key:
                                    context.read<TutorialCubit>().chatButtonKey,
                                icon: Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            AppSpacing.xs),
                                        border: Border.all(
                                            color: AppColors.neutral[500]!,
                                            width: 1),
                                      ),
                                      child: Icon(Icons.add,
                                          color: AppColors.neutral[500],
                                          size: 20),
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  // context.read<ChatCubit>().sendMessage();
                                  Analytics().logEvent('채팅_인증하기_버튼클릭');
                                  _showBottomSheet(context);
                                },
                              )
                            : Container(
                                padding: const EdgeInsets.all(2),
                              ),
                      ]),
                  messageListOptions: MessageListOptions(
                    dateSeparatorBuilder: (date) => Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(
                        top: AppSpacing.m,
                        bottom: AppSpacing.xxs,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.neutral[800]?.withAlpha(100),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s,
                          vertical: 6,
                        ),
                        child: Text(
                          '${date.year}년 ${date.month}월 ${date.day}일',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                      ),
                    ),
                  ),
                  messageOptions: MessageOptions(
                    showCurrentUserAvatar: false,
                    showOtherUsersAvatar: true,
                    messageRowBuilder: (ChatMessage message,
                        ChatMessage? previousMessage,
                        ChatMessage? nextMessage,
                        bool isAfterDateSeparator,
                        bool isBeforeDateSeparator) {
                      bool isFirstInSequence = previousMessage == null ||
                          previousMessage.user.id != message.user.id ||
                          isAfterDateSeparator;
                      bool isLastInSequence = nextMessage == null ||
                          nextMessage.user.id != message.user.id ||
                          isBeforeDateSeparator;

                      bool isLastInRoom = nextMessage == null; // ✅ 핵심

                      return ChatBubble(
                        message: message,
                        isMine: message.customProperties?['message'].isMine,
                        isFirstInSequence: isFirstInSequence,
                        isLastInSequence: isLastInSequence,
                        memberCount: roomInfo.members.length,
                        isLastInRoom: isLastInRoom,
                      );
                    },
                  ),
                  onSend: (ChatMessage message) {
                    // context.read<ChatCubit>().sendMessage(message.text);
                    Analytics().logEvent('채팅_메시지전송', parameters: {
                      'room_id': roomInfo.id,
                      'message': message.text,
                    });
                    context
                        .read<ChatCubit>()
                        .sendMessage(message.text, "textMessage", roomInfo.id);
                  },
                  messages: asDashChatMessages(messages),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ChatUser asDashChatUser(String userId, String firstName) {
    return ChatUser(
      id: userId,
      firstName: firstName,
    );
  }

  List<ChatMessage> asDashChatMessages(List<Message> messages) {
    List<ChatMessage> result = [];
    for (var message in messages) {
      String user = message.userId;
      // Profile profile = message.profile;
      if (message.type == "textMessage") {
        result.add(
          ChatMessage(
              createdAt: message.createdAt!,
              text: message.content ?? "",
              user: asDashChatUser(user, message.profile?.nickname ?? user),
              customProperties: {
                // 'reactions': message.reactions,
                'messageId': message.id,
                'channelUrl': message.roomId,
                // 'unreadCount': message.readReceipts.length,
                'message': message,
              }),
        );
      } else if (message.type == "imageMessage") {
        result.add(
          ChatMessage(
              createdAt: message.createdAt!,
              user: asDashChatUser(user, message.profile?.nickname ?? user),
              medias: (message.imageUrl != null
                  ? [
                      ChatMedia(
                        url: message.imageUrl!,
                        fileName: "사진",
                        type: MediaType.image,
                      )
                    ]
                  : []),
              customProperties: {
                // 'reactions': message.reactions,
                'messageId': message.id,
                'channelUrl': message.roomId,
                // 'unreadCount': message.readReceipts.length,
                'message': message,
              }),
        );
      } else if (message.type == 'missionMessage') {
        result.add(
          ChatMessage(
              createdAt: message.createdAt!,
              user: asDashChatUser(user, message.profile?.nickname ?? user),
              text: message.content ?? "",
              medias: (message.imageUrl != null
                  ? [
                      ChatMedia(
                        url: message.imageUrl!,
                        fileName: "사진",
                        type: MediaType.image,
                      )
                    ]
                  : []),
              customProperties: {
                // 'reactions': message.reactions,
                'messageId': message.id,
                'channelUrl': message.roomId,
                // 'unreadCount': message.readReceipts.length,
                'message': message,
              }),
        );
      }
    }

    return result;
  }
}
