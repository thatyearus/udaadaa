import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:udaadaa/models/message.dart';
import 'package:udaadaa/models/room.dart';
import 'package:udaadaa/utils/constant.dart';

class ImageListView extends StatelessWidget {
  const ImageListView(
      {super.key, required this.roomInfo, required this.imageMessages});

  final Room roomInfo;
  final List<Message> imageMessages;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          roomInfo.roomName,
          style: AppTextStyles.textTheme.headlineLarge,
        ),
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: imageMessages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: CachedNetworkImage(
              imageUrl: imageMessages[index].imageUrl!,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
