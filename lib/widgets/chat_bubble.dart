import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/models/profile.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/chat/image_detail_view.dart';
import 'package:udaadaa/view/chat/profile_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter/services.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.isFirstInSequence,
    required this.isLastInSequence,
    required this.memberCount,
    required this.isLastInRoom,
    this.isDeletedMessage = false,
    this.createdAt,
  });

  final ChatMessage message;
  final bool isMine;
  final bool isFirstInSequence;
  final bool isLastInSequence;
  final int memberCount;
  final bool isLastInRoom;
  final bool? isDeletedMessage;
  final DateTime? createdAt;
  void _showReactionOverlay(BuildContext context, bool isInDialog) {
    if (isInDialog) return;
    showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: AppColors.black.withValues(alpha: 0.25),
      transitionDuration: const Duration(milliseconds: 500),
      transitionBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: 4 * animation.value, sigmaY: 4 * animation.value),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      context: context,
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
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
                        children: ['👍', '❤️', '✔️'].map((emoji) {
                          return GestureDetector(
                            onTap: () {
                              // 리액션 선택 처리
                              context.read<ChatCubit>().sendReaction(
                                  message.customProperties?['message'].roomId ??
                                      "",
                                  message.customProperties?['message'].id,
                                  emoji);
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
                              // 메세지 차단 로직
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('메세지 차단'),
                                    content: const Text('메세지를 차단하시겠습니까?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          context
                                              .read<ChatCubit>()
                                              .blockMessage(
                                                  message
                                                          .customProperties?[
                                                              'message']
                                                          .id ??
                                                      "",
                                                  message
                                                          .customProperties?[
                                                              'message']
                                                          .roomId ??
                                                      "");
                                        },
                                        child: const Text('확인'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text(
                              '메세지 차단',
                              style: AppTextStyles.bodyLarge(
                                  TextStyle(color: AppColors.grayscale[800])),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // 차단하기 로직
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('사용자 차단'),
                                    content: const Text('사용자를 차단하시겠습니까?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          context.read<ChatCubit>().blockUser(
                                              message
                                                      .customProperties?[
                                                          'message']
                                                      .userId ??
                                                  "");
                                        },
                                        child: const Text('확인'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text(
                              '사용자 차단',
                              style: AppTextStyles.bodyLarge(
                                  TextStyle(color: AppColors.grayscale[800])),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // 복사하기 로직
                              try {
                                final messageText = message.text;
                                if (messageText.isNotEmpty) {
                                  Clipboard.setData(
                                      ClipboardData(text: messageText));
                                }
                              } catch (e) {
                                debugPrint('Error copying message: $e');
                              } finally {
                                Navigator.pop(context);
                              }
                            },
                            child: Text(
                              '복사하기',
                              style: AppTextStyles.bodyLarge(
                                  TextStyle(color: AppColors.grayscale[800])),
                            ),
                          ),
                          if (message.customProperties?['message'].isMine ==
                              true)
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('모든 대화 상대에게서 삭제'),
                                      content: const Text(
                                          '선택한 메시지를 모든 채팅 참가자에게서 삭제합니다. 삭제된 메시지는 "삭제된 메시지입니다"로 표시됩니다. 정말 삭제하시겠습니까?'),
                                      actions: <Widget>[
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  '취소',
                                                  style: TextStyle(
                                                      color: const Color(
                                                          0xFF2563EB),
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: TextButton(
                                                onPressed: () {
                                                  try {
                                                    context
                                                        .read<ChatCubit>()
                                                        .deleteMessage(message
                                                                .customProperties?[
                                                                    'message']
                                                                .id ??
                                                            "");
                                                    debugPrint(
                                                        '메시지 삭제 요청 성공: ${message.customProperties?['message'].id}');
                                                  } catch (e) {
                                                    debugPrint(
                                                        'Error deleting message: $e');
                                                  } finally {
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                  }
                                                },
                                                child: Text(
                                                  '삭제',
                                                  style: TextStyle(
                                                      color: AppColors.red[600],
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Text(
                                '메세지 삭제',
                                style: AppTextStyles.bodyLarge(
                                        TextStyle(color: AppColors.red[600]))
                                    .copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
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

  void _showDetailReactions(BuildContext context, bool isInDialog) {
    if (isInDialog) return;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          List<String> emojis = [];
          List<Profile?> members = [];

          for (var reaction in message.customProperties?['message'].reactions) {
            emojis.add(reaction.content);
            Profile? profile = context.read<ChatCubit>().getProfile(
                message.customProperties?['message'].roomId ?? "",
                reaction.userId);
            members.add(profile);
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
                      title: Text(members[index]?.nickname ?? "정보 없음"),
                      trailing: CircleAvatar(
                        backgroundColor: AppColors.neutral[100],
                        child: Text(emojis[index],
                            style: AppTextStyles.bodyLarge(
                                const TextStyle(fontFamily: 'tossface'))),
                      ),
                      onTap: () => (members[index] != null
                          ? navigateToProfileView(
                              context,
                              members[index]?.nickname ?? "정보 없음",
                              members[index]?.id ?? "")
                          : null),
                    );
                  },
                ),
              ],
            ),
          );
        });
  }

  Widget _buildReaction(BuildContext context, bool isInDialog) {
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
            onTap: () => _showDetailReactions(context, isInDialog),
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
    final readReceipt =
        memberCount - message.customProperties?['message'].readReceipts.length;
    List<Widget> bubbleContents = [
      Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          (message.medias != null &&
                  message.medias!.isNotEmpty &&
                  message.text != '')
              ? GestureDetector(
                  onLongPress: () => _showReactionOverlay(context, isInDialog),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isMine
                          ? AppColors.primary[200]
                          : AppColors.neutral[100],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                    ),
                    child: Linkify(
                      onOpen: (link) async {
                        try {
                          final Uri url = Uri.parse(link.url);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url,
                                mode: LaunchMode.externalApplication);
                          } else {
                            throw Exception('Could not launch $url');
                          }
                        } catch (e) {
                          debugPrint('Error launching URL: $e');
                        }
                      },
                      text: message.text,
                      style: AppTextStyles.bodyLarge(
                        TextStyle(
                          color: AppColors.neutral[800],
                        ),
                      ),
                      linkStyle: AppTextStyles.bodyLarge(
                        TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          (message.medias != null &&
                  message.medias!.isNotEmpty &&
                  message.text != '')
              ? AppSpacing.verticalSizedBoxXs
              : const SizedBox.shrink(),
          GestureDetector(
            onLongPress: () => _showReactionOverlay(context, isInDialog),
            onTap: () {
              if (message.medias != null && message.medias!.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageDetailView(
                      imageMessage: message.customProperties?['message'],
                      roomInfo: context.read<ChatCubit>().getRoom(
                            message.customProperties?['message'].roomId ?? "",
                          ),
                    ),
                  ),
                );
              }
            },
            child: Container(
              padding: (message.medias == null || message.medias!.isEmpty)
                  ? const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    )
                  : null,
              decoration: (message.medias == null || message.medias!.isEmpty)
                  ? BoxDecoration(
                      color: isMine
                          ? AppColors.primary[200]
                          : AppColors.neutral[100],
                      borderRadius: BorderRadius.circular(14),
                    )
                  : null,
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6,
              ),
              child: (message.medias == null || message.medias!.isEmpty
                  ? Linkify(
                      onOpen: (link) async {
                        try {
                          final Uri url = Uri.parse(link.url);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url,
                                mode: LaunchMode.externalApplication);
                          } else {
                            throw Exception('Could not launch $url');
                          }
                        } catch (e) {
                          debugPrint('Error launching URL: $e');
                        }
                      },
                      text: message.text,
                      style: AppTextStyles.bodyLarge(
                        TextStyle(
                          color:
                              message.customProperties?['isDeletedMessage'] ==
                                      true
                                  ? AppColors.neutral[600]
                                  : AppColors.neutral[800],
                        ),
                      ),
                      linkStyle: AppTextStyles.bodyLarge(
                        TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                        ),
                      ),
                    )
                  : (message.medias != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CachedNetworkImage(
                              imageUrl: message.medias![0].url),
                        )
                      : const CircularProgressIndicator())),
            ),
          ),
        ],
      ),
      const SizedBox(width: 4),
      Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              (readReceipt > 0) ? readReceipt.toString() : '',
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
          ? GestureDetector(
              onTap: () => navigateToProfileView(
                  context, message.user.firstName ?? "", message.user.id),
              child: CircleAvatar(
                backgroundColor: AppColors.primary[50],
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                ),
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
          : EdgeInsets.fromLTRB(
              AppSpacing.xs,
              4,
              AppSpacing.xs,
              isLastInRoom ? 16 : 4, // 👈 마지막 메시지면 아래 패딩을 크게
            ),
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
            _buildReaction(context, isInDialog),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return bubble(context);
  }
}
