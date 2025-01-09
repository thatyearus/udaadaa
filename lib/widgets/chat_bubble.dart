import 'package:cached_network_image/cached_network_image.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/models/profile.dart';
import 'package:udaadaa/utils/constant.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.isFirstInSequence,
    required this.isLastInSequence,
  });

  final ChatMessage message;
  final bool isMine;
  final bool isFirstInSequence;
  final bool isLastInSequence;

  void _showReactionOverlay(BuildContext context, bool isInDialog) {
    if (isInDialog) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16),
                /*decoration: BoxDecoration(
                color: AppColors.neutral[100],
                borderRadius: BorderRadius.circular(16),
              ),*/
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: isMine
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    // 리액션 선택 부분
                    Container(
                      margin: EdgeInsets.only(left: isMine ? 0 : 40 + 12),
                      child: Wrap(
                        spacing: AppSpacing.m,
                        children: ['👍', '❤️', '✔️', '👍🏻'].map((emoji) {
                          return GestureDetector(
                            onTap: () {
                              // 리액션 선택 처리
                              Navigator.pop(context);
                            },
                            child: CircleAvatar(
                              backgroundColor: AppColors.neutral[100],
                              child: Text(
                                emoji,
                                style: AppTextStyles.titleLarge(
                                  const TextStyle(
                                    fontFamily: 'tossface',
                                  ),
                                ),
                              ), // 리액션 아이콘
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    bubble(context, isInDialog: true),
                    const SizedBox(height: 16),

                    // 옵션
                    Container(
                      margin: EdgeInsets.only(left: isMine ? 0 : 40 + 12),
                      decoration: BoxDecoration(
                        color: AppColors.neutral[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          TextButton(
                            onPressed: () {
                              // 신고하기 로직
                              Navigator.pop(context);
                            },
                            child: Text(
                              '신고하기',
                              style: AppTextStyles.bodyLarge(
                                  TextStyle(color: AppColors.grayscale[800])),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // 차단하기 로직
                              Navigator.pop(context);
                            },
                            child: Text(
                              '차단하기',
                              style: AppTextStyles.bodyLarge(
                                  TextStyle(color: AppColors.grayscale[800])),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // 복사하기 로직
                              Navigator.pop(context);
                            },
                            child: Text(
                              '복사하기',
                              style: AppTextStyles.bodyLarge(
                                  TextStyle(color: AppColors.grayscale[800])),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDetailReactions(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          List<String> emojis = [];
          List<String> members = [];

          for (var reaction in message.customProperties?['message'].reactions) {
            emojis.add(reaction.content);
            Profile? profile = context.read<ChatCubit>().getProfile(
                message.customProperties?['message'].roomId ?? "",
                reaction.userId);
            members.add(profile?.nickname ?? "정보 없음");
          }
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const ListTile(
                  title: Text('공감한 사람'),
                ),
                const Divider(),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: emojis.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(members[index]),
                      trailing: CircleAvatar(
                        backgroundColor: AppColors.neutral[100],
                        child: Text(emojis[index],
                            style: AppTextStyles.bodyLarge(
                                const TextStyle(fontFamily: 'tossface'))),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        });
  }

  Widget _buildReaction(BuildContext context) {
    Map<String, int> reactionCounts = {};
    for (var reaction in message.customProperties?['message'].reactions) {
      if (reactionCounts.containsKey(reaction.content)) {
        reactionCounts[reaction.content] =
            reactionCounts[reaction.content]! + 1;
      } else {
        reactionCounts[reaction.content] = 1;
      }
    }

    return Container(
      padding: EdgeInsets.only(left: (isMine ? 0 : 40 + 12)),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showDetailReactions(context),
            child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.neutral[800]?.withAlpha(100),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    for (var reaction in reactionCounts.entries)
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.neutral[100],
                            radius: 10,
                            child: Text(
                              reaction.key,
                              style: AppTextStyles.labelSmall(
                                const TextStyle(
                                  fontFamily: 'tossface',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            reaction.value.toString(),
                            style: AppTextStyles.labelSmall(
                              const TextStyle(
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          if (reactionCounts.entries.last.key != reaction.key)
                            const SizedBox(width: 8),
                        ],
                      ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget bubble(BuildContext context, {bool isInDialog = false}) {
    List<Widget> bubbleContents = [
      GestureDetector(
        onLongPress: () => _showReactionOverlay(context, isInDialog),
        child: Container(
          padding: (message.medias == null || message.medias!.isEmpty)
              ? const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 10,
                )
              : null,
          decoration: (message.medias == null || message.medias!.isEmpty)
              ? BoxDecoration(
                  color:
                      isMine ? AppColors.primary[200] : AppColors.neutral[100],
                  borderRadius: BorderRadius.circular(10),
                )
              : null,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6,
          ),
          child: (message.medias == null || message.medias!.isEmpty
              ? Text(
                  message.text,
                  style: AppTextStyles.bodyLarge(
                    TextStyle(
                      color: AppColors.neutral[800],
                    ),
                  ),
                )
              : (message.medias != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child:
                          CachedNetworkImage(imageUrl: message.medias![0].url),
                    )
                  : const CircularProgressIndicator())),
        ),
      ),
      const SizedBox(width: 4),
      Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.customProperties?['message'].readReceipts.length
                      .toString() ??
                  "",
              style: AppTextStyles.labelSmall(
                  const TextStyle(color: AppColors.primary)),
            ),
            if (isLastInSequence)
              Text(DateFormat('HH:mm').format(message.createdAt),
                  style: AppTextStyles.textTheme.labelSmall),
          ])
    ];
    if (isMine) {
      bubbleContents = bubbleContents.reversed.toList();
    }
    List<Widget> chatContents = [
      (!isMine && isFirstInSequence)
          ? CircleAvatar(
              backgroundColor: AppColors.primary[50],
              child: const Icon(
                Icons.person,
                color: AppColors.primary,
              ),
            )
          : !isMine
              ? const SizedBox(width: 40)
              : const SizedBox.shrink(),
      if (!isMine) const SizedBox(width: 12),
      Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMine && isFirstInSequence)
              Text(message.user.firstName ?? "",
                  style: AppTextStyles.textTheme.labelMedium),
            if (!isMine && isFirstInSequence) const SizedBox(height: 8),
            Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: bubbleContents),
          ]),
    ];
    if (isMine) {
      chatContents = chatContents.reversed.toList();
    }
    return Padding(
      padding: isInDialog
          ? const EdgeInsets.all(0)
          : const EdgeInsets.symmetric(vertical: 4, horizontal: AppSpacing.xs),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (isFirstInSequence) const SizedBox(height: 8),
          Row(
            mainAxisAlignment:
                isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: chatContents,
          ),
          if (message.customProperties?['message'].reactions.isNotEmpty)
            const SizedBox(height: 4),
          if (message.customProperties?['message'].reactions.isNotEmpty)
            _buildReaction(context),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return bubble(context);
  }
}
