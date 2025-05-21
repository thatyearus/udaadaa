import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/challenge_cubit.dart';

class ResultCard extends StatelessWidget {
  final bool isSuccess;
  final DateTime e;

  const ResultCard({
    super.key,
    required this.isSuccess,
    required this.e,
  });

  @override
  Widget build(BuildContext context) {
    final nickname = context.watch<AuthCubit>().getProfile?.nickname ?? "챌린저";

    final startWeight = context.watch<ChallengeCubit>().getStartWeight;
    final endWeight = context.watch<ChallengeCubit>().getEndWeight;

    String weightDiff = '';
    if (endWeight != null && startWeight != null) {
      weightDiff = (endWeight - startWeight).toStringAsFixed(1);
    }
    // final now = DateTime.now();
    // final e = DateTime(now.year, now.month, now.day);
    final s = e.subtract(const Duration(days: 13));

    final dateFormat = DateFormat('yy.MM.dd');
    final endDay = dateFormat.format(e);
    final startDay = dateFormat.format(s);

    String successMessage = endWeight != null && startWeight != null
        ? "$nickname님\n챌린지 성공을 축하합니다!\n$startDay - $endDay 동안\n매일 모든 미션을 성공했습니다.\n\n총 ${weightDiff}kg 감량 성공\n축하드립니다!"
        : "$nickname님\n챌린지 성공을 축하합니다!\n$startDay - $endDay 동안\n매일 모든 미션을 성공했습니다.\n\n축하드립니다!";

    String failMessage =
        "$nickname님\n아쉽게도 지난 이주일 동안\n진행한 챌린지에 실패하셨습니다.\n\n실패는 성공의 어머니입니다.\n건강한 다이어트 습관을 만들기 위해\n한번 더 챌린지에 도전해 보세요!";

    // 체중이 증가했는지 확인
    bool isWeightIncreased =
        endWeight != null && startWeight != null && endWeight > startWeight;

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: AppSpacing.edgeInsetsL,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.l),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5),
            spreadRadius: 8,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            (isSuccess && !isWeightIncreased) ? '👏' : '😅',
            style: const TextStyle(
              fontSize: 80,
              fontFamily: 'tossface',
            ),
          ),
          AppSpacing.verticalSizedBoxS,
          Text(
            '우다다',
            style: AppTextStyles.displayMedium(
              const TextStyle(color: AppColors.primary),
            ),
          ),
          Text(
            (isSuccess && !isWeightIncreased) ? '챌린지 성공' : '챌린지 실패',
            style: AppTextStyles.textTheme.displayMedium!,
          ),
          AppSpacing.sizedBoxL,
          Text(
            (isSuccess && !isWeightIncreased) ? successMessage : failMessage,
            textAlign: TextAlign.center,
            style: AppTextStyles.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
