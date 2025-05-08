import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/register/enter_room_view.dart';
import 'package:app_links/app_links.dart';
import 'package:udaadaa/view/register/email_login_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => current is AuthKakaoLoginSuccess,
      listener: (context, state) {
        if (state is AuthKakaoLoginSuccess) {
          try {
            logger.i('카카오 로그인 성공: 화면 전환');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const EnterRoomView(),
              ),
            );
          } catch (e) {
            logger.e('화면 전환 중 오류 발생: ${e.toString()}');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          automaticallyImplyLeading: false,
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
                      style: AppTextStyles.displayLarge(
                        TextStyle(color: AppColors.primary),
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
                    onPressed: () async {
                      bool isInstalled = true;
                      try {
                        isInstalled = await isKakaoTalkInstalled();
                      } catch (e) {
                        debugPrint('카카오톡 설치 확인 중 오류 발생: ${e.toString()}');
                        isInstalled = true;
                      }
                      debugPrint('isInstalled: $isInstalled');

                      Analytics().logEvent('로그인_카카오로그인');
                      // 카카오 로그인 로직 추가
                      if (!context.mounted) {
                        return;
                      }
                      try {
                        if (isInstalled) {
                          context.read<AuthCubit>().signInWithKakao().then((_) {
                            final appLinks = AppLinks();
                            appLinks.uriLinkStream.listen((Uri? uri) {
                              if (uri != null &&
                                  uri.scheme == schemeName &&
                                  uri.host == hostName) {
                                if (!context.mounted) return;
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const EnterRoomView(),
                                  ),
                                );
                              }
                            });
                          }).catchError((e) {
                            logger.e(e.toString());
                          });
                        } else {
                          await context
                              .read<AuthCubit>()
                              .signInWithKakaoByWebView();
                        }
                      } catch (e) {
                        logger.e('카카오 로그인 중 오류 발생: ${e.toString()}');
                      }
                    },
                  ),
                  AppSpacing.verticalSizedBoxS,
                  _buildSocialLoginButton(
                    "Apple로 계속하기",
                    "assets/apple_icon.png",
                    AppColors.black,
                    textColor: AppColors.white,
                    onPressed: () {
                      Analytics().logEvent('로그인_애플로그인');
                      // 애플 로그인 로직 추가
                      if (Platform.isAndroid) {
                        /*context
                            .read<AuthCubit>()
                            .signInWithAppleAndroid()
                            .then((_) {
                          final appLinks = AppLinks();
                          appLinks.uriLinkStream.listen((Uri? uri) {
                            if (uri != null &&
                                uri.scheme == schemeName &&
                                uri.host == hostName) {
                              if (!context.mounted) return;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const EnterRoomView(),
                                ),
                              );
                            }
                          });
                        }).catchError((e) {
                          logger.e(e.toString());
                        });*/
                        // Android에서는 Apple 로그인을 지원하지 않는다는 팝업창을 띄웁니다

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            actionsOverflowDirection: VerticalDirection.down,
                            actions: [
                              Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: AppSpacing.s),
                                        foregroundColor: AppColors.white,
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        minimumSize:
                                            const Size(double.infinity, 0),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        '확인',
                                        style: AppTextStyles
                                            .textTheme.headlineSmall
                                            ?.copyWith(
                                          color: AppColors
                                              .neutral[800], // 텍스트 색상 설정
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            title: Text('알림',
                                style: AppTextStyles.textTheme.headlineMedium),
                            content: Text('Android에서는 Apple 로그인을 지원하지 않습니다.',
                                style: AppTextStyles.textTheme.bodyLarge),
                          ),
                        );
                        return;
                      }
                      context.read<AuthCubit>().signInWithApple().then((_) {
                        if (!context.mounted) return;
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
                  TextButton(
                    onPressed: () {
                      // 이메일 로그인 로직 추가 예정
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EmailLoginView(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.neutral[400],
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.s),
                    ),
                    child: Text(
                      '이메일로 로그인하기',
                      style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                        color: AppColors.neutral[400],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  AppSpacing.verticalSizedBoxXxl,
                ],
              ),
            ),
          ],
        ),
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
