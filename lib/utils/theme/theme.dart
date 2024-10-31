import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_style.dart';

final ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: AppColors.primary,
    accentColor: AppColors.secondary,
  ).copyWith(outline: AppColors.neutral[50]),
  textTheme: AppTextStyles.textTheme,
  fontFamily: 'pretendard',
);
