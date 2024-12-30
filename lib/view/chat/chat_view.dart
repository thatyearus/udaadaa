import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/models/message.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/widgets/chat_bubble.dart';

/// Page to chat with someone.
///
/// Displays chat bubbles as a ListView and TextField to enter new chat.
class ChatView extends StatelessWidget {
  const ChatView({super.key});

  /*static Route<void> route(String roomId) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider<ChatCubit>(
        create: (context) => ChatCubit()..setMessagesListener(roomId),
        child: const ChatPage(),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    final messages =
        context.select<ChatCubit, List<Message>>((cubit) => cubit.getMessages);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: AppColors.primary[100],
        surfaceTintColor: AppColors.primary[100],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        child: DashChat(
          currentUser: asDashChatUser(supabase.auth.currentUser!.id, 'User'),
          inputOptions: InputOptions(
            sendOnEnter: false,
            textInputAction: TextInputAction.send,
            inputMaxLines: 2,
            inputTextStyle: Theme.of(context).textTheme.bodyMedium,
            inputDecoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(17),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(17),
                ),
              ),
            ),
            leading: [
              IconButton(
                icon: const Icon(Icons.photo),
                onPressed: () async {
                  // final img = await context.read<ChatCubit>().pickImage();
                  // context.read<ChatCubit>().sendFileMessage(img);
                },
              ),
            ],
          ),
          messageListOptions: MessageListOptions(
            dateSeparatorBuilder: (date) => Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black12.withAlpha(50),
                  borderRadius: BorderRadius.circular(17),
                ),
                padding: const EdgeInsets.all(8),
                child: Text(
                  '${date.year}년 ${date.month}월 ${date.day}일',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
              bool isLastInSequence =
                  nextMessage == null || nextMessage.user.id != message.user.id;
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
          },
          messages: asDashChatMessages(messages),
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
              createdAt: message.createdAt,
              text: message.content ?? "",
              user: asDashChatUser(user, user),
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
              createdAt: message.createdAt,
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
