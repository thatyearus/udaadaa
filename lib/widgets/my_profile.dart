import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/models/profile.dart';
import 'package:udaadaa/utils/constant.dart';

class MyProfile extends StatelessWidget {
  const MyProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final profile =
        context.select<AuthCubit, Profile?>((cubit) => cubit.getProfile);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral[0],
        border: Border.all(color: AppColors.primary[100]!),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary[100]!,
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      padding: AppSpacing.edgeInsetsM,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary[50],
            child: const Icon(Icons.person, color: AppColors.primary, size: 30),
          ),
          AppSpacing.horizontalSizedBoxS,
          Text(
            profile?.nickname ?? 'Not Logged In',
            style: AppTextStyles.textTheme.bodyLarge,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 15, top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '목표 몸무게',
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(
                    color: AppColors.grayscale[500],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${profile?.weight?.toStringAsFixed(1) ?? '-'}kg',
                  style: AppTextStyles.textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
