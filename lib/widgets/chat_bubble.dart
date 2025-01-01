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
    Map<String, String> reactionKeys = {
      'thumb_up': '👍',
      'heart': '❤️',
      'smile': '😊',
    };

    /*
    for (var reaction in message.reactions) {
      emojis.add(reactionKeys[reaction.reaction]!);
      members.add(reaction.profileId);
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
                      trailing: Text(emojis[index],
                          style: Theme.of(context).textTheme.bodyLarge),
                    );
                  },
                ),
              ],
            ),
          );
        });*/
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> bubbleContents = [
      Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12,
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
              "1",
              style: AppTextStyles.labelSmall(
                  const TextStyle(color: AppColors.primary)),
            ),
            // TODO: change read receipt to actual number of read receipts
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
          ? const CircleAvatar(
              child: Icon(
                Icons.person,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          if (isFirstInSequence) const SizedBox(height: 8),
          Row(
            mainAxisAlignment:
                isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: chatContents,
          ),
        ],
      ),
    );
  }
}
