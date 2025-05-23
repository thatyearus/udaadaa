import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/detail/my_record_view.dart';
import 'package:udaadaa/view/mypage/push_setting_view.dart';
import 'package:udaadaa/view/newonboarding/onboarding_login_view.dart';
import 'package:udaadaa/widgets/my_profile.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/analytics/analytics.dart';
import 'package:udaadaa/view/mypage/refund_view.dart';

class MyPageView extends StatelessWidget {
  const MyPageView({super.key});

  Future<void> _launchURL() async {
    const url = 'https://open.kakao.com/o/sxSYCkWg';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  // void showLinkEmailDialog(BuildContext context, String type) {
  //   final emailController = TextEditingController();
  //   final passwordController = TextEditingController();
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       actionsOverflowDirection: VerticalDirection.down,
  //       actions: [
  //         Column(
  //           children: [
  //             SizedBox(
  //               width: double.infinity,
  //               child: ElevatedButton(
  //                 style: ElevatedButton.styleFrom(
  //                   padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
  //                   foregroundColor: Theme.of(context).primaryColor,
  //                   backgroundColor: Colors.white,
  //                   shape: RoundedRectangleBorder(
  //                     side: BorderSide(color: Theme.of(context).primaryColor),
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                   minimumSize: const Size(double.infinity, 0),
  //                 ),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 child:
  //                     Text('취소', style: AppTextStyles.textTheme.headlineSmall),
  //               ),
  //             ),
  //             AppSpacing.verticalSizedBoxS,
  //             SizedBox(
  //               width: double.infinity,
  //               child: ElevatedButton(
  //                 style: ElevatedButton.styleFrom(
  //                   padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
  //                   foregroundColor: AppColors.white,
  //                   backgroundColor: AppColors.primary,
  //                   shape: RoundedRectangleBorder(
  //                     side: BorderSide(color: Theme.of(context).primaryColor),
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                   minimumSize: const Size(double.infinity, 0),
  //                 ),
  //                 onPressed: () async {
  //                   int success = -1;
  //                   if (type == "link_email") {
  //                     // 이메일 계정 연동
  //                     success = await context.read<AuthCubit>().linkEmail(
  //                         emailController.text, passwordController.text);
  //                   } else {
  //                     // 계정 복원
  //                     success = await context.read<AuthCubit>().signInWithEmail(
  //                         emailController.text, passwordController.text);
  //                   }
  //                   if (!context.mounted) return;
  //                   Navigator.of(context).pop(success);
  //                 },
  //                 child: Text(
  //                   type == 'link_email' ? '이메일 계정 연동하기' : '계정 복원하기',
  //                   style: AppTextStyles.textTheme.headlineSmall?.copyWith(
  //                     color: AppColors.white, // 텍스트 색상 설정
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //       title: Text(type == 'link_email' ? '이메일 계정 연동' : '계정 복원',
  //           style: AppTextStyles.textTheme.headlineMedium),
  //       content: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text(
  //               type == 'link_email'
  //                   ? '이메일을 계정과 연동하시면 데이터를 나중에 복원할 수 있습니다.'
  //                   : '계정을 복원하시려면 연동한 이메일과 비밀번호를 입력해 주세요.',
  //               style: AppTextStyles.textTheme.bodyLarge),
  //           (type == 'link_email')
  //               ? const SizedBox()
  //               : Text(
  //                   "현재 계정의 데이터는 삭제되니 주의하세요.",
  //                   style: AppTextStyles.labelMedium(
  //                     TextStyle(color: AppColors.neutral[500]),
  //                   ),
  //                 ),
  //           AppSpacing.verticalSizedBoxS,
  //           Row(children: [
  //             Expanded(
  //               child: TextField(
  //                 controller: emailController,
  //                 decoration: InputDecoration(
  //                   labelText: '이메일',
  //                   labelStyle: AppTextStyles.labelLarge(
  //                       TextStyle(color: AppColors.neutral[500])),
  //                   enabledBorder: UnderlineInputBorder(
  //                     borderSide: BorderSide(color: AppColors.neutral[300]!),
  //                   ),
  //                   focusedBorder: const UnderlineInputBorder(
  //                     borderSide: BorderSide(color: AppColors.primary),
  //                   ),
  //                   floatingLabelBehavior: FloatingLabelBehavior.always,
  //                 ),
  //               ),
  //             ),
  //           ]),
  //           Row(children: [
  //             Expanded(
  //               child: TextField(
  //                 obscureText: true,
  //                 controller: passwordController,
  //                 decoration: InputDecoration(
  //                   labelText: '비밀번호',
  //                   labelStyle: AppTextStyles.labelLarge(
  //                       TextStyle(color: AppColors.neutral[500])),
  //                   enabledBorder: UnderlineInputBorder(
  //                     borderSide: BorderSide(color: AppColors.neutral[300]!),
  //                   ),
  //                   focusedBorder: const UnderlineInputBorder(
  //                     borderSide: BorderSide(color: AppColors.primary),
  //                   ),
  //                   floatingLabelBehavior: FloatingLabelBehavior.always,
  //                 ),
  //               ),
  //             ),
  //           ]),
  //         ],
  //       ),
  //     ),
  //   ).then((value) {
  //     if (value == null || value == -1) return;
  //     if (!context.mounted) return;
  //     String textMessage = "";
  //     switch (value) {
  //       case 0:
  //         textMessage = "이메일 계정 연동에 실패했습니다.";
  //         break;

  //       case 1:
  //         textMessage = "이메일 계정 연동이 완료되었습니다.";
  //         break;

  //       case 2:
  //         textMessage = "계정 복원에 실패했습니다.";
  //         break;

  //       case 3:
  //         textMessage = "계정 복원이 완료되었습니다.";
  //         break;

  //       case 4:
  //         textMessage = "비밀번호는 최소 6자리 이상이어야 합니다.";
  //         break;

  //       case 5:
  //         textMessage = "이미 연동된 이메일입니다. 다른 이메일로 시도해주세요.";
  //         break;

  //       case 6:
  //         textMessage = "이메일 형식이 올바르지 않습니다.";
  //         break;

  //       case 7:
  //         textMessage = "이메일 형식이 올바르지 않습니다.";
  //         break;

  //       case 8:
  //         textMessage = "이메일 또는 비밀번호가 일치하지 않습니다.";
  //         break;

  //       default:
  //     }
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(textMessage),
  //       ),
  //     );
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final myFeeds =
        context.select((FeedCubit feedCubit) => feedCubit.getMyFeeds);

    return Scaffold(
      appBar: AppBar(actions: [
        PopupMenuButton(
          itemBuilder: (context) {
            return [
              const PopupMenuItem(
                value: 'change_nickname',
                child: Text('닉네임 변경'),
              ),
              const PopupMenuItem(
                value: 'change_calorie',
                child: Text('칼로리 설정'),
              ),
              PopupMenuItem(
                value: 'push_setting',
                child: Text('알림 설정'),
              ),
              const PopupMenuItem(
                value: 'kakaotalk',
                child: Text('문의하기'),
              ),
              const PopupMenuItem(
                value: 'refund_policy',
                child: Text('상금규정'),
              ),
              // const PopupMenuItem(
              //   value: 'withdraw',
              //   child: Text('회원탈퇴'),
              // ),
              // const PopupMenuItem(
              //   value: 'link_email',
              //   child: Text('이메일 연동'),
              // ),
              // const PopupMenuItem(
              //   value: 'account_restore',
              //   child: Text("계정 복원"),
              // ),
            ];
          },
          onSelected: (value) {
            switch (value) {
              case 'change_nickname':
                Analytics().logEvent(
                  "마이페이지_닉네임",
                  parameters: {
                    "클릭": "닉네임변경",
                    "챌린지상태": context.read<AuthCubit>().getChallengeStatus(),
                  },
                );
                final nicknameController = TextEditingController();
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('닉네임 변경'),
                        content: TextField(
                          decoration: InputDecoration(
                            hintText: '변경할 닉네임을 입력해주세요',
                            hintStyle: AppTextStyles.labelLarge(
                                TextStyle(color: AppColors.neutral[500])),
                          ),
                          controller: nicknameController,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Analytics().logEvent(
                                "마이페이지_닉네임",
                                parameters: {
                                  "클릭": "취소",
                                  "챌린지상태": context
                                      .read<AuthCubit>()
                                      .getChallengeStatus(),
                                },
                              );
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              '취소',
                              style: AppTextStyles.bodyLarge(
                                TextStyle(color: AppColors.neutral[800]),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Analytics().logEvent(
                                "마이페이지_닉네임",
                                parameters: {
                                  "클릭": "확인",
                                  "챌린지상태": context
                                      .read<AuthCubit>()
                                      .getChallengeStatus(),
                                },
                              );
                              context
                                  .read<AuthCubit>()
                                  .updateNickname(nicknameController.text);
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              '확인',
                              style: AppTextStyles.bodyLarge(
                                TextStyle(color: AppColors.neutral[800]),
                              ),
                            ),
                          ),
                        ],
                      );
                    });
                break;
              case 'change_calorie':
                Analytics().logEvent(
                  "마이페이지_칼로리",
                  parameters: {
                    "클릭": "칼로리변경",
                    "챌린지상태": context.read<AuthCubit>().getChallengeStatus(),
                  },
                );
                final heightController = TextEditingController();
                final weightController = TextEditingController();
                final profile = context.read<AuthCubit>().getCurProfile;
                if (profile?.height != null) {
                  heightController.text = profile!.height.toString();
                }
                if (profile?.weight != null) {
                  weightController.text = profile!.weight.toString();
                }
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('키와 목표 몸무게 변경'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: heightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: '키 (cm)',
                              hintText: '키를 입력해주세요',
                              hintStyle: AppTextStyles.labelLarge(
                                TextStyle(color: AppColors.neutral[500]),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: '목표 몸무게 (kg)',
                              hintText: '목표 몸무게를 입력해주세요',
                              hintStyle: AppTextStyles.labelLarge(
                                TextStyle(color: AppColors.neutral[500]),
                              ),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Analytics().logEvent(
                              "마이페이지_칼로리",
                              parameters: {
                                "클릭": "취소",
                                "챌린지상태": context
                                    .read<AuthCubit>()
                                    .getChallengeStatus(),
                              },
                            );
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            '취소',
                            style: AppTextStyles.bodyLarge(
                              TextStyle(color: AppColors.neutral[800]),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Analytics().logEvent(
                              "마이페이지_칼로리",
                              parameters: {
                                "클릭": "확인",
                                "챌린지상태": context
                                    .read<AuthCubit>()
                                    .getChallengeStatus(),
                              },
                            );
                            context.read<AuthCubit>().updateProfile(
                                  heightController.text,
                                  weightController.text,
                                );
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            '확인',
                            style: AppTextStyles.bodyLarge(
                              TextStyle(color: AppColors.neutral[800]),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
                break;
              case 'push_setting':
                Analytics().logEvent(
                  "마이페이지_푸시알림",
                  parameters: {
                    "클릭": "알림설정",
                    "챌린지상태": context.read<AuthCubit>().getChallengeStatus(),
                  },
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const PushSettingView()),
                );
                break;
              case 'kakaotalk':
                Analytics().logEvent(
                  "마이페이지_문의하기",
                  parameters: {
                    "클릭": "문의하기",
                    "챌린지상태": context.read<AuthCubit>().getChallengeStatus(),
                  },
                );
                _launchURL();
                break;
              case 'refund_policy':
                Analytics().logEvent(
                  "마이페이지_환급규정",
                  parameters: {
                    "클릭": "환급규정",
                    "챌린지상태": context.read<AuthCubit>().getChallengeStatus(),
                  },
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RefundView(),
                  ),
                );
                break;
              case 'withdraw':
                Analytics().logEvent(
                  "마이페이지_회원탈퇴",
                  parameters: {
                    "클릭": "회원탈퇴",
                    "챌린지상태": context.read<AuthCubit>().getChallengeStatus(),
                  },
                );
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('회원탈퇴'),
                    content: const Text('회원을 탈퇴하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Analytics().logEvent(
                            "마이페이지_회원탈퇴",
                            parameters: {
                              "클릭": "취소",
                              "챌린지상태": context
                                  .read<AuthCubit>()
                                  .getChallengeStatus(),
                            },
                          );
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                        child: const Text('아니요'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Analytics().logEvent(
                            "마이페이지_회원탈퇴",
                            parameters: {
                              "클릭": "확인",
                              "챌린지상태": context
                                  .read<AuthCubit>()
                                  .getChallengeStatus(),
                            },
                          );
                          try {
                            await context.read<AuthCubit>().withdrawAccount();
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const OnboardingLoginView(),
                              ),
                              (route) => false,
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('회원탈퇴 중 오류가 발생했습니다.'),
                              ),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('예'),
                      ),
                    ],
                  ),
                );
                break;
            }
          },
          icon: const Icon(Icons.settings_rounded),
        ),
      ]),
      body: RefreshIndicator(
        onRefresh: () => context.read<FeedCubit>().fetchMyFeeds(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MyProfile(),
              AppSpacing.verticalSizedBoxL,
              GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: myFeeds.length,
                  itemBuilder: (context, index) {
                    return GridTile(
                      child: GestureDetector(
                        onTap: () {
                          Analytics().logEvent(
                            "마이페이지_피드",
                            parameters: {
                              "피드선택": index,
                              "챌린지상태": context
                                  .read<AuthCubit>()
                                  .getChallengeStatus(),
                            },
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  MyRecordView(initialPage: index),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: CachedNetworkImage(
                                width: double.infinity,
                                height: double.infinity,
                                imageUrl: myFeeds[index].imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Container(
                                  alignment: Alignment.center,
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: AppColors.neutral[500]
                                      ?.withValues(alpha: 0.5),
                                  child: Text(
                                    (myFeeds[index].calorie != null
                                        ? "${myFeeds[index].calorie} ${myFeeds[index].type == FeedType.exercise ? "분" : "kcal"}"
                                        : ""),
                                    style: AppTextStyles.headlineSmall(
                                      TextStyle(
                                          color: AppColors.neutral[200],
                                          shadows: [
                                            Shadow(
                                              color: AppColors.neutral[500]!,
                                              offset: const Offset(0, 1),
                                              blurRadius: 0,
                                            )
                                          ]),
                                    ),
                                    textAlign: TextAlign.center,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
