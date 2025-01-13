import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';

import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/cubit/form_cubit.dart';
import 'package:udaadaa/models/message.dart';
import 'package:udaadaa/models/room.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/chat/profile_view.dart';
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

  Drawer showDrawer(BuildContext context) {
    List<Message> imagemessages = context.select<ChatCubit, List<Message>>(
        (cubit) => cubit
            .getMessagesByRoomId(roomInfo.id)
            .where((element) => element.type == "imageMessage")
            .toList());
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
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child:
                Text('사진 모아보기', style: Theme.of(context).textTheme.titleSmall),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppSpacing.xxs,
            ),
            itemCount: min(imagemessages.length, 3),
            itemBuilder: (context, index) {
              return Container(
                decoration: const BoxDecoration(color: AppColors.primary),
                child: CachedNetworkImage(
                  imageUrl: imagemessages[index].imageUrl!,
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
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary[50],
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                  title: Text(roomInfo.members[index].nickname,
                      style: Theme.of(context).textTheme.bodyMedium),
                  onTap: () {
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
            leading: IconButton(
              icon: Icon(Icons.logout, color: AppColors.neutral[500]),
              onPressed: () {},
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
            ),
            trailing: IconButton(
              icon: /*Icon(_pushTriggerOption == GroupChannelPushTriggerOption.off
                  ? Icons.notifications_off
                  : Icons.notifications_active),*/

                  Icon(Icons.notifications_active,
                      color: AppColors.neutral[500]),
              //  onPressed: _toogglePushOption,
              onPressed: () {},
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
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
                          }
                        },
                      ),
                      AppSpacing.verticalSizedBoxXs,
                      Text(
                        '인증',
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
    final messages = context.select<ChatCubit, List<Message>>(
        (cubit) => cubit.getMessagesByRoomId(roomInfo.id));
    final userName = context.select<AuthCubit, String>(
        (cubit) => cubit.getCurProfile?.nickname ?? "");
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<ChatCubit>().leaveRoom(roomInfo.id);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(roomInfo.roomName),
          backgroundColor: AppColors.primary[100],
          surfaceTintColor: AppColors.primary[100],
        ),
        endDrawer: showDrawer(context),
        body: Column(
          children: [
            Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s, vertical: AppSpacing.xxs),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.25),
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
                          '우측 하단의 + 버튼을 눌러 인증을 진행해 주세요.',
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
                    sendOnEnter: false,
                    textInputAction: TextInputAction.newline,
                    inputMaxLines: 2,
                    inputToolbarMargin: EdgeInsets.zero,
                    inputToolbarPadding: const EdgeInsets.all(2),
                    inputToolbarStyle:
                        BoxDecoration(color: AppColors.white, boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.1),
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
                      IconButton(
                        icon: Icon(Icons.photo_outlined,
                            color: AppColors.neutral[500]),
                        onPressed: () {
                          context
                              .read<ChatCubit>()
                              .sendImageMessage(roomInfo.id);
                          // final img = await context.read<ChatCubit>().pickImage();
                          // context.read<ChatCubit>().sendFileMessage(img);
                        },
                      ),
                    ],
                    trailing: [
                      IconButton(
                        icon: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.xs),
                                border: Border.all(
                                    color: AppColors.neutral[500]!, width: 1),
                              ),
                              child: Icon(Icons.add,
                                  color: AppColors.neutral[500], size: 20),
                            ),
                          ],
                        ),
                        onPressed: () {
                          // context.read<ChatCubit>().sendMessage();
                          _showBottomSheet(context);
                        },
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                    return ChatBubble(
                      message: message,
                      isMine: message.customProperties?['message'].isMine,
                      isFirstInSequence: isFirstInSequence,
                      isLastInSequence: isLastInSequence,
                      memberCount: roomInfo.members.length,
                    );
                  },
                ),
                onSend: (ChatMessage message) {
                  // context.read<ChatCubit>().sendMessage(message.text);
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
              user: asDashChatUser(user, user),
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
              user: asDashChatUser(user, user),
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
