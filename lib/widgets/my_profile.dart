import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/utils/constant.dart';

class MyProfile extends StatelessWidget {
  const MyProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthCubit>().getProfile;
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
          const CircleAvatar(
            radius: 30,
            child: Icon(Icons.person),
          ),
          AppSpacing.horizontalSizedBoxS,
          Text(
            profile?.nickname ?? 'Not Logged In',
            style: AppTextStyles.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
