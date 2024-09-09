import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/utils/constant.dart';

class MyProfile extends StatelessWidget {
  const MyProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthCubit>().getProfile;
    return Row(
      children: [
        const CircleAvatar(
          radius: 30,
          child: Icon(Icons.person),
        ),
        AppSpacing.horizontalSizedBoxS,
        Text(profile?.nickname ?? 'Not Logged In'),
      ],
    );
  }
}
