import 'package:flutter/material.dart';
import 'package:udaadaa/models/message.dart';
import 'package:intl/intl.dart';
import 'package:udaadaa/utils/constant.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isFirstInSequence,
    required this.isLastInSequence,
  });

  final Message message;
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
          color:
              message.isMine ? AppColors.primary[500] : AppColors.neutral[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: (message.type == "textMessage"
            ? Text(
                message.content ?? "",
                style: AppTextStyles.bodyLarge(
                  TextStyle(
                      color: message.isMine
                          ? AppColors.white
                          : AppColors.neutral[800]),
                ),
              )
            : (message.image != null
                ? Image.memory(message.image!)
                : const CircularProgressIndicator())),
      ),
      const SizedBox(width: 4),
      Column(
          crossAxisAlignment: message.isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              "1",
              style:
                  AppTextStyles.labelSmall(TextStyle(color: AppColors.primary)),
            ),
            // TODO: change read receipt to actual number of read receipts
            if (isLastInSequence)
              Text(DateFormat('HH:mm').format(message.createdAt),
                  style: AppTextStyles.textTheme.labelSmall),
          ])
    ];
    if (message.isMine) {
      bubbleContents = bubbleContents.reversed.toList();
    }
    List<Widget> chatContents = [
      if (!message.isMine && isFirstInSequence)
        const CircleAvatar(
          child: Icon(
            Icons.person,
          ),
        ),
      if (!message.isMine && isFirstInSequence) const SizedBox(width: 12),
      Column(
          crossAxisAlignment: message.isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!message.isMine && isFirstInSequence)
              Text(message.userId, style: AppTextStyles.textTheme.labelMedium),
            if (!message.isMine && isFirstInSequence) const SizedBox(height: 8),
            Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: bubbleContents),
          ]),
    ];
    if (message.isMine) {
      chatContents = chatContents.reversed.toList();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          if (isFirstInSequence) const SizedBox(height: 8),
          Row(
            mainAxisAlignment: message.isMine
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: chatContents,
          ),
        ],
      ),
    );
  }
}
