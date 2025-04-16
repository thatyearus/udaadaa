import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:udaadaa/models/message.dart';
import 'package:udaadaa/models/room.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

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

  Future<void> _saveImageToGallery(BuildContext context) async {
    try {
      final scaffold = ScaffoldMessenger.of(context);
      // Show loading indicator
      scaffold.showSnackBar(
        const SnackBar(
            content: Text('이미지 저장 중...'),
            duration: Duration(milliseconds: 500)),
      );

      // Download image using Dio
      final response = await Dio().get(
        imageMessage.imageUrl!,
        options: Options(responseType: ResponseType.bytes),
      );

      // Save image to gallery
      final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: "udaadaa_${DateTime.now().millisecondsSinceEpoch}",
      );

      // Show success message
      scaffold.showSnackBar(
        const SnackBar(content: Text('이미지가 갤러리에 저장되었습니다')),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 저장 실패: ${e.toString()}')),
      );
    }
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
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: () => _saveImageToGallery(context),
            tooltip: '이미지 저장하기',
          ),
        ],
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
