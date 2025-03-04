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
  bool _isButtonEnabled = false;

  void showTutorial(BuildContext context) {
    final onboardingCubit = context.read<TutorialCubit>();

    TutorialCoachMark tutorialCoachMark = TutorialCoachMark(
      hideSkip: true,
      targets: [
        /*TargetFocus(
          identify: "challenge_code",
          keyTarget: onboardingCubit.challengeCodeKey,
          contents: [TargetContent(child: Text("여기에 챌린지 코드를 입력하세요!"))],
        ),*/
        TargetFocus(
          identify: "enter_room_code",
          keyTarget: onboardingCubit.enterRoomKey,
          shape: ShapeLightFocus.RRect,
          radius: 8,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              child: Container(
                padding: AppSpacing.edgeInsetsS,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "챌린지 입장 코드를 입력하세요.",
                  style: AppTextStyles.textTheme.bodyMedium,
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
    setState(() {
      _isButtonEnabled = value.isNotEmpty;
    });
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
                      context
                          .read<ChatCubit>()
                          .joinRoom(_codeController.text)
                          .then((_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("채팅방에 입장했습니다."),
                          ),
                        );
                        context
                            .read<BottomNavCubit>()
                            .selectTab(BottomNavState.chat);
                        Navigator.of(context).popUntil(
                          (route) => route.isFirst,
                        );
                        context.read<TutorialCubit>().showTutorialRoom();
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
