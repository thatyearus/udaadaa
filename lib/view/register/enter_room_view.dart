import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:udaadaa/cubit/bottom_nav_cubit.dart';
import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/cubit/tutorial_cubit.dart';
import 'package:udaadaa/service/shared_preferences.dart';
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

  void showTutorial(BuildContext context) {
    final onboardingCubit = context.read<TutorialCubit>();

    TutorialCoachMark tutorialCoachMark = TutorialCoachMark(
      hideSkip: false,
      onSkip: () {
        logger.d("스킵 누름 - enter_room_view");
        Analytics().logEvent("튜토리얼_스킵", parameters: {
          "view": "enter_room_view", // 현재 튜토리얼이 실행된 뷰
        });
        PreferencesService().setBool('isTutorialFinished', true);
        return true; // 👈 튜토리얼 종료
      },
      alignSkip: Alignment.topLeft,
      skipWidget: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: const Text(
          "SKIP",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      targets: [
        TargetFocus(
          identify: "enter_room_code",
          keyTarget: onboardingCubit.enterRoomKey,
          shape: ShapeLightFocus.RRect,
          radius: 8,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              child: Text(
                "문자로 받으신 코드를 입력해주세요.",
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  color: Colors.white, // 흰색 글씨
                  fontWeight: FontWeight.bold, // 글씨 굵기 (Bold)
                  fontSize: 18, // 글씨 크기 증가
                ),
              ),
            ),
          ],
        ),
      ],
      onClickTarget: (target) {
        Analytics().logEvent('튜토리얼_입장코드',
            parameters: {'target': target.identify.toString()});
        logger.d("onClickTarget: ${target.identify}");
      },
      onFinish: () {
        logger.d("finish tutorial enter room view");
      },
    );

    tutorialCoachMark.show(context: context);
  }

  void _onTextChanged(String value) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted &&
            PreferencesService().getBool('isTutorialFinished') != true) {
          showTutorial(context);
        }
      });
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
              key: context.read<TutorialCubit>().enterRoomKey,
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
                if (state is JoinRoomSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("채팅방에 입장했습니다.")),
                  );
                  context.read<BottomNavCubit>().selectTab(BottomNavState.chat);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (context.mounted) {
                      context.read<TutorialCubit>().showTutorialRoom();
                    }
                  });
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
                                Analytics().logEvent('입장코드뷰_다음');
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
