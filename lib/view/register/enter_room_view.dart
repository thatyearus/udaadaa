import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/bottom_nav_cubit.dart';
import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:url_launcher/url_launcher.dart';

class EnterRoomView extends StatefulWidget {
  const EnterRoomView({super.key});

  @override
  State<EnterRoomView> createState() => _EnterRoomViewState();
}

class _EnterRoomViewState extends State<EnterRoomView> {
  final TextEditingController _codeController = TextEditingController();
  bool _isButtonEnabled = false;

  void _onTextChanged(String value) {
    setState(() {
      _isButtonEnabled = value.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: AppSpacing.edgeInsetsL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              "입장 코드를 입력해주세요.",
              style: AppTextStyles.textTheme.headlineLarge,
            ),
            AppSpacing.verticalSizedBoxM,
            TextField(
              controller: _codeController,
              onChanged: _onTextChanged,
              decoration: InputDecoration(
                hintText: "코드를 입력하세요",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            AppSpacing.verticalSizedBoxM,
            // 코드가 없으신가요? 텍스트와 링크
            Row(
              children: [
                Text(
                  "코드가 없으신가요?",
                  style: AppTextStyles.textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: () async {
                    const url =
                        'https://slashpage.com/dietchallenge'; // 랜딩페이지 링크 갱신되면 변경 필요.
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: Text(
                    "여기를 클릭하세요",
                    style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // 다음 버튼
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isButtonEnabled
                    ? AppColors.primary
                    : AppColors.grayscale[300],
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isButtonEnabled
                  ? () {
                      // 다음 단계 이동 로직 추가 필요.
                      context
                          .read<ChatCubit>()
                          .joinRoom(_codeController.text)
                          .then((_) {
                        context
                            .read<BottomNavCubit>()
                            .selectTab(BottomNavState.chat);
                        Navigator.of(context).popUntil(
                          (route) => route.isFirst,
                        );
                      }).catchError((e) {
                        logger.e(e.toString());
                      });
                    }
                  : null,
              child: Text(
                "다음",
                style: AppTextStyles.textTheme.headlineMedium?.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            AppSpacing.verticalSizedBoxXxl,
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
