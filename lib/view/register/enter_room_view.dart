import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/bottom_nav_cubit.dart';
import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/models/profile.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:url_launcher/url_launcher.dart';

class EnterRoomView extends StatefulWidget {
  const EnterRoomView({super.key});

  @override
  State<EnterRoomView> createState() => _EnterRoomViewState();
}

class _EnterRoomViewState extends State<EnterRoomView> {
  final TextEditingController _codeController = TextEditingController();

  void _onTextChanged(String value) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
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
                    Analytics().logEvent('랜딩페이지이동', parameters: {
                      "view": "enter_room_view",
                      "챌린지상태": context.read<AuthCubit>().getChallengeStatus(),
                    });
                    const url = 'https://dietchallenge.udadaa24.workers.dev/';
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
            BlocListener<ChatCubit, ChatState>(
              listener: (context, state) {
                Profile? profile = context.read<AuthCubit>().getCurProfile;
                if (profile != null && profile.fcmToken == null) {
                  context.read<AuthCubit>().setFCMToken();
                }
                if (state is JoinRoomSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("채팅방에 입장했습니다.")),
                  );
                  context.read<BottomNavCubit>().selectTab(BottomNavState.chat);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  final isLoading = state is JoinRoomLoading;
                  final isFailed = state is JoinRoomFailed;
                  final errorMessage = isFailed ? state.reason : null;
                  final isEnabled =
                      !isLoading && _codeController.text.trim().isNotEmpty;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            errorMessage,
                            style: AppTextStyles.bodyMedium(
                              const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600, // ✅ 굵게 추가
                              ),
                            ),
                          ),
                        ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isEnabled
                              ? AppColors.primary
                              : AppColors.grayscale[300],
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isEnabled
                            ? () {
                                Analytics().logEvent('입장코드뷰_다음', parameters: {
                                  "챌린지상태": context
                                      .read<AuthCubit>()
                                      .getChallengeStatus(),
                                });
                                context.read<ChatCubit>().joinRoomByRoomName(
                                    _codeController.text.trim());
                              }
                            : null,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : Text(
                                "다음",
                                style: AppTextStyles.textTheme.headlineMedium
                                    ?.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                      ),
                    ],
                  );
                },
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
