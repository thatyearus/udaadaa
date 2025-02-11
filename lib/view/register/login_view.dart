import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/register/enter_room_view.dart';
import 'package:app_links/app_links.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24.0, top: 36.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "우다다",
                    style: AppTextStyles.textTheme.displayLarge?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFB6C1), // 핑크색
                    ),
                  ),
                  AppSpacing.verticalSizedBoxXs,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("챌린지에 참여하시려면",
                          style: AppTextStyles.textTheme.displaySmall),
                      Text("로그인이 필요합니다",
                          style: AppTextStyles.textTheme.displaySmall),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Spacer(flex: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildSocialLoginButton(
                  "카카오로 계속하기",
                  "assets/kakao_icon.png",
                  const Color(0xFFFFD700),
                  onPressed: () {
                    // 카카오 로그인 로직 추가
                    context.read<AuthCubit>().signInWithKakao().then((_) {
                      final appLinks = AppLinks();
                      appLinks.uriLinkStream.listen((Uri? uri) {
                        if (uri != null &&
                            uri.scheme == schemeName &&
                            uri.host == hostName) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const EnterRoomView(),
                            ),
                          );
                        }
                      });
                    }).catchError((e) {
                      logger.e(e.toString());
                    });
                    /*
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const EnterRoomView(),
                      ),
                    );*/
                  },
                ),
                AppSpacing.verticalSizedBoxS,
                _buildSocialLoginButton(
                  "Apple로 계속하기",
                  "assets/apple_icon.png",
                  AppColors.black,
                  textColor: AppColors.white,
                  onPressed: () {
                    // 애플 로그인 로직 추가
                    context.read<AuthCubit>().signInWithApple().then((_) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EnterRoomView(),
                        ),
                      );
                    }).catchError((e) {
                      logger.e(e.toString());
                    });
                  },
                ),
                AppSpacing.verticalSizedBoxXxl,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLoginButton(
    String text,
    String? iconPath,
    Color backgroundColor, {
    Color? textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor ?? AppColors.black,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Stack(
        children: [
          if (iconPath != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.m),
                child: Image.asset(
                  iconPath,
                  height: 24,
                  width: 24,
                ),
              ),
            ),
          Center(
            child: Text(
              text,
              style: AppTextStyles.textTheme.headlineSmall?.copyWith(
                color: textColor ?? AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
