import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:udaadaa/models/message.dart';
import 'package:udaadaa/models/room.dart';
import 'package:udaadaa/utils/constant.dart';

class ImageDetailView extends StatelessWidget {
  const ImageDetailView({
    super.key,
    required this.imageMessage,
    required this.roomInfo,
  });

  final Message imageMessage;
  final Room roomInfo;

  String formatTime(DateTime timestamp) {
    String year = timestamp.year.toString();
    String month = timestamp.month.toString().padLeft(2, '0');
    String day = timestamp.day.toString().padLeft(2, '0');
    String hour = timestamp.hour.toString().padLeft(2, '0');
    String minute = timestamp.minute.toString().padLeft(2, '0');

    return '$year-$month-$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(roomInfo.memberMap[imageMessage.userId]?.nickname ?? "",
                style: AppTextStyles.textTheme.headlineSmall),
            Text(formatTime(imageMessage.createdAt!),
                style: AppTextStyles.textTheme.bodyMedium),
          ],
        ),
      ),
      body: CachedNetworkImage(
        imageUrl: imageMessage.imageUrl!,
        fit: BoxFit.contain,
        height: double.infinity,
        width: double.infinity,
      ),
    );
  }
}
