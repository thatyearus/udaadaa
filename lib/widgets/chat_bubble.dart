import 'package:cached_network_image/cached_network_image.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  void _showDetailReactions(BuildContext context) {
    List<String> emojis = [];
    List<String> members = [];

    for (var reaction in message.customProperties?['message'].reactions) {
      emojis.add(reaction.content);
      members.add(reaction.userId);
      // TODO: get user name from user id
    }

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    List<Widget> bubbleContents = [
      Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primary[200] : AppColors.neutral[100],
          borderRadius: BorderRadius.circular(10),
        ),
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
                ? CachedNetworkImage(imageUrl: message.medias![0].url)
                : const CircularProgressIndicator())),
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
      padding:
          const EdgeInsets.symmetric(vertical: 4, horizontal: AppSpacing.xs),
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
}
