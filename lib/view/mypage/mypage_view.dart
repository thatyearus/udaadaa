import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/detail/my_record_view.dart';
import 'package:udaadaa/widgets/my_profile.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/analytics/analytics.dart';

class MyPageView extends StatelessWidget {
  const MyPageView({super.key});

  Future<void> _launchURL() async {
    const url = 'http://pf.kakao.com/_lxjxgkG';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

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
                value: 'push_setting',
                child: Text('푸시알림 설정'),
              ),
              const PopupMenuItem(
                value: 'kakaotalk',
                child: Text('문의하기'),
              ),
            ];
          },
          onSelected: (value) {
            switch (value) {
              case 'change_nickname':
                Analytics().logEvent(
                  "마이페이지_닉네임",
                  parameters: {"클릭": "닉네임변경"},
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
                                parameters: {"클릭": "취소"},
                              );
                              Navigator.of(context).pop();
                            },
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              Analytics().logEvent(
                                "마이페이지_닉네임",
                                parameters: {"클릭": "확인"},
                              );
                              context
                                  .read<AuthCubit>()
                                  .updateNickname(nicknameController.text);
                              Navigator.of(context).pop();
                            },
                            child: const Text('확인'),
                          ),
                        ],
                      );
                    });
                break;
              case 'push_setting':
                Analytics().logEvent(
                  "마이페이지_푸시알림",
                  parameters: {"클릭": "푸시알림설정"},
                );
                context.read<AuthCubit>().togglePush();
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('푸시알림 설정'),
                        content: const Text('푸시알림 설정이 변경되었습니다.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('확인'),
                          ),
                        ],
                      );
                    });
                break;
              case 'kakaotalk':
                Analytics().logEvent(
                  "마이페이지_문의하기",
                  parameters: {"클릭": "문의하기"},
                );
                _launchURL();
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
                            parameters: {"피드선택": index},
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
                                  color:
                                      AppColors.neutral[500]?.withOpacity(0.5),
                                  child: Text(
                                    (myFeeds[index].calorie != null
                                        ? "${myFeeds[index].calorie} kcal"
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
