import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/widgets/result_card.dart';

class ChallengeResultView extends StatelessWidget {
  final bool isSuccess;
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  ChallengeResultView({super.key, required this.isSuccess});

  Future<void> _saveImage(BuildContext context) async {
    try {
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final result = await ImageGallerySaver.saveImage(
          byteData.buffer.asUint8List(),
          quality: 100,
          name: "challenge_result.png",
        );

        if (context.mounted) {
          if (result['isSuccess']) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('이미지가 저장되었습니다!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('이미지 저장에 실패했습니다.')),
            );
          }
        }
      }
    } catch (e) {
      logger.e(e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지 저장에 실패했습니다.')),
        );
      }
    }
  }

  Future<void> _shareImage() async {
    try {
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 임시 디렉토리에 이미지 파일 저장
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/challenge_result.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      // 공유하기
      await Share.shareXFiles([XFile(imagePath)], text: '챌린지 결과를 확인하세요!');
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Spacer(flex: 2),
            RepaintBoundary(
              key: _repaintBoundaryKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: ResultCard(isSuccess: isSuccess),
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    context,
                    icon: Icons.save_alt,
                    label: '저장하기',
                    onPressed: () => _saveImage(context),
                  ),
                  _buildActionButton(
                    context,
                    icon: Icons.share,
                    label: '공유하기',
                    onPressed: () => _shareImage(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(150, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: AppColors.primary),
        ),
        textStyle: AppTextStyles.textTheme.headlineSmall,
        foregroundColor: AppColors.primary, // 기본 텍스트 색상
        backgroundColor: Colors.white, // 기본 배경색
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return AppColors.primary;
          }
          return Colors.white;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.white;
          }
          return AppColors.primary;
        }),
      ),
    );
  }
}
