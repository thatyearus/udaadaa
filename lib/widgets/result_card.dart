import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';

class ResultCard extends StatelessWidget {
  final bool isSuccess;

  ResultCard({
    super.key,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final nickname = context.watch<AuthCubit>().getProfile?.nickname ?? "챌린저";

    final now = DateTime.now();
    final e = DateTime(now.year, now.month, now.day);
    final s = e.subtract(const Duration(days: 6));

    final dateFormat = DateFormat('yy.MM.dd');
    final endDay = dateFormat.format(e);
    final startDay = dateFormat.format(s);

    String successMessage =
        "$nickname님\n챌린지 성공을 축하합니다!\n$startDay - $endDay 동안\n매일 모든 미션을 성공했습니다.\n\n건강한 다이어트 습관을\n꾸준히 유지해 보세요!";
    String failMessage =
        "$nickname님\n아쉽게도 지난 일주일 동안\n진행한 챌린지에 실패하셨습니다.\n\n실패는 성공의 어머니입니다.\n건강한 다이어트 습관을 만들기 위해\n한번 더 챌린지에 도전해 보세요!";

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
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
            isSuccess ? '👏' : '😅',
            style: const TextStyle(
              fontSize: 80,
              fontFamily: 'tossface',
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '우다다',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            isSuccess ? '챌린지 성공' : '챌린지 실패',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.sizedBoxL,
          Text(
            isSuccess ? successMessage : failMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
