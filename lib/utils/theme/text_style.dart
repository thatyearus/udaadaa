import 'package:flutter/material.dart';

class AppTextStyles {
  // #1 Primitive Text Styles
  static const textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
    ),
    headlineLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
    ),
    titleMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w400,
    ),
    titleSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w200,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w200,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w200,
    ),
  );

  // #2 Merged Text Styles
  static TextStyle displayLarge(TextStyle? style) {
    return textTheme.displayLarge!.merge(style);
  }

  static TextStyle displayMedium(TextStyle? style) {
    return textTheme.displayMedium!.merge(style);
  }

  static TextStyle displaySmall(TextStyle? style) {
    return textTheme.displaySmall!.merge(style);
  }

  static TextStyle headlineLarge(TextStyle? style) {
    return textTheme.headlineLarge!.merge(style);
  }

  static TextStyle headlineMedium(TextStyle? style) {
    return textTheme.headlineMedium!.merge(style);
  }

  static TextStyle headlineSmall(TextStyle? style) {
    return textTheme.headlineSmall!.merge(style);
  }

  static TextStyle titleLarge(TextStyle? style) {
    return textTheme.titleLarge!.merge(style);
  }

  static TextStyle titleMedium(TextStyle? style) {
    return textTheme.titleMedium!.merge(style);
  }

  static TextStyle titleSmall(TextStyle? style) {
    return textTheme.titleSmall!.merge(style);
  }

  static TextStyle bodyLarge(TextStyle? style) {
    return textTheme.bodyLarge!.merge(style);
  }

  static TextStyle bodyMedium(TextStyle? style) {
    return textTheme.bodyMedium!.merge(style);
  }

  static TextStyle bodySmall(TextStyle? style) {
    return textTheme.bodySmall!.merge(style);
  }

  static TextStyle labelLarge(TextStyle? style) {
    return textTheme.labelLarge!.merge(style);
  }

  static TextStyle labelMedium(TextStyle? style) {
    return textTheme.labelMedium!.merge(style);
  }

  static TextStyle labelSmall(TextStyle? style) {
    return textTheme.labelSmall!.merge(style);
  }
}
