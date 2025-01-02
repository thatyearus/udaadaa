import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';

import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/models/message.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/widgets/chat_bubble.dart';

/// Page to chat with someone.
///
/// Displays chat bubbles as a ListView and TextField to enter new chat.
class ChatView extends StatelessWidget {
  const ChatView({super.key, required this.roomId});

  /*static Route<void> route(String roomId) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider<ChatCubit>(
        create: (context) => ChatCubit()..setMessagesListener(roomId),
        child: const ChatPage(),
      ),
    );
  }*/
  final String roomId;

  @override
  Widget build(BuildContext context) {
    final messages =
        context.select<ChatCubit, List<Message>>((cubit) => cubit.getMessages);
    final userName = context.select<AuthCubit, String>(
        (cubit) => cubit.getCurProfile?.nickname ?? "");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: AppColors.primary[100],
        surfaceTintColor: AppColors.primary[100],
      ),
      body: Column(
        children: [
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
                      onPressed: () async {
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
                      previousMessage.user.id != message.user.id;
                  bool isLastInSequence = nextMessage == null ||
                      nextMessage.user.id != message.user.id;
                  return ChatBubble(
                    message: message,
                    isMine: message.customProperties?['message'].isMine,
                    isFirstInSequence: isFirstInSequence,
                    isLastInSequence: isLastInSequence,
                  );
                },
              ),
              onSend: (ChatMessage message) {
                // context.read<ChatCubit>().sendMessage(message.text);
                context
                    .read<ChatCubit>()
                    .sendMessage(message.text, "textMessage", roomId);
              },
              messages: asDashChatMessages(messages),
            ),
          ),
        ],
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
      } else if (message.type == "FileMessage") {
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
      }
    }

    return result;
  }
}
