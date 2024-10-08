import 'package:flutter/material.dart';

class AppColors {
  // #1 Primitive Colors
  static const MaterialColor red = MaterialColor(0xFFE85146, <int, Color>{
    50: Color(0xFFFCECEF),
    100: Color(0xFFF9CFD4),
    200: Color(0xFFE69EA0),
    300: Color(0xFFDA7A7B),
    400: Color(0xFFE35E5C),
    500: Color(0xFFE85146),
    600: Color(0xFFD94944),
    700: Color(0xFFC7403D),
    800: Color(0xFFBA3B37),
    900: Color(0xFFA9332D),
  });

  static const MaterialColor orange = MaterialColor(
    0xFFFC5A19,
    <int, Color>{
      50: Color(0xFFFBE9E6),
      100: Color(0xFFFECCBB),
      200: Color(0xFFFEAC8F),
      300: Color(0xFFFD8B61),
      400: Color(0xFFFC723E),
      500: Color(0xFFFC5A19),
      600: Color(0xFFF15415),
      700: Color(0xFFE34D10),
      800: Color(0xFFD5460C),
      900: Color(0xFFBC3903),
    },
  );

  static const MaterialColor grayscale = MaterialColor(
    0xFF000000,
    <int, Color>{
      0: Color(0xFFFFFFFF),
      50: Color(0xFFF5F5F5),
      100: Color(0xFFE9E9E9),
      200: Color(0xFFD9D9D9),
      300: Color(0xFFC4C4C4),
      400: Color(0xFF9D9D9D),
      500: Color(0xFF7B7B7B),
      600: Color(0xFF555555),
      700: Color(0xFF434343),
      800: Color(0xFF262626),
      900: Color(0xFF000000),
    },
  );

  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);

  // #2 Semantic Colors
  static const MaterialColor primary = red;
  static const MaterialColor secondary = orange;
  static const MaterialColor neutral = grayscale;
}
