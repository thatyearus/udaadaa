import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/detail/my_record_view.dart';
import 'package:udaadaa/view/form/food_form_view.dart';
import 'package:udaadaa/widgets/my_profile.dart';

import '../../utils/analytics/analytics.dart';

class MyPageView extends StatelessWidget {
  const MyPageView({super.key});

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
            ];
          },
          onSelected: (value) {
            switch (value) {
              case 'change_nickname':
                Analytics().logEvent("마이페이지_닉네임",
                  parameters: {"클릭": "닉네임변경"},);
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
                              Analytics().logEvent("마이페이지_닉네임",
                                parameters: {"클릭": "취소"},);
                              Navigator.of(context).pop();
                            },
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              Analytics().logEvent("마이페이지_닉네임",
                                parameters: {"클릭": "확인"},);
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
            }
          },
          icon: const Icon(Icons.settings_rounded),
        ),
      ]),
      body: RefreshIndicator(
        onRefresh: () => context.read<FeedCubit>().fetchMyFeeds(),
        child: SingleChildScrollView(
          padding: AppSpacing.edgeInsetsL,
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
                          Analytics().logEvent("마이페이지_피드",
                            parameters: {"피드선택": index},);
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
                                    "${myFeeds[index].calorie} kcal",
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
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        width: double.infinity,
        child: FloatingActionButton.extended(
          onPressed: () {
            Analytics().logEvent("마이페이지_공감받으러가기");
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FoodFormView(),
              ),
            );
          },
          label: Text(
            '반응 받으러 가기',
            style: AppTextStyles.textTheme.headlineLarge,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
