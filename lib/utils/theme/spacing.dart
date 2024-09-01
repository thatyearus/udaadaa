import 'package:flutter/material.dart';

class AppSpacing {
  // #1 Values
  static const double xxs = 4;
  static const double xs = 8;
  static const double s = 12;
  static const double m = 16;
  static const double l = 20;
  static const double xl = 24;
  static const double xxl = 32;

  // #2 EdgeInsets
  static const EdgeInsets edgeInsetsXxs = EdgeInsets.all(xxs);
  static const EdgeInsets edgeInsetsXs = EdgeInsets.all(xs);
  static const EdgeInsets edgeInsetsS = EdgeInsets.all(s);
  static const EdgeInsets edgeInsetsM = EdgeInsets.all(m);
  static const EdgeInsets edgeInsetsL = EdgeInsets.all(l);
  static const EdgeInsets edgeInsetsXxl = EdgeInsets.all(xxl);
  static const EdgeInsets edgeInsetsXl = EdgeInsets.all(xl);

  // #3 SizedBox
  static const SizedBox sizedBoxXxs = SizedBox(height: xxs, width: xxs);
  static const SizedBox sizedBoxXs = SizedBox(height: xs, width: xs);
  static const SizedBox sizedBoxS = SizedBox(height: s, width: s);
  static const SizedBox sizedBoxM = SizedBox(height: m, width: m);
  static const SizedBox sizedBoxL = SizedBox(height: l, width: l);
  static const SizedBox sizedBoxXl = SizedBox(height: xl, width: xl);
  static const SizedBox sizedBoxXxl = SizedBox(height: xxl, width: xxl);

  // #4 Vertical SizedBox
  static const SizedBox verticalSizedBoxXxs = SizedBox(height: xxs);
  static const SizedBox verticalSizedBoxXs = SizedBox(height: xs);
  static const SizedBox verticalSizedBoxS = SizedBox(height: s);
  static const SizedBox verticalSizedBoxM = SizedBox(height: m);
  static const SizedBox verticalSizedBoxL = SizedBox(height: l);
  static const SizedBox verticalSizedBoxXl = SizedBox(height: xl);
  static const SizedBox verticalSizedBoxXxl = SizedBox(height: xxl);

  // #5 Horizontal SizedBox
  static const SizedBox horizontalSizedBoxXxs = SizedBox(width: xxs);
  static const SizedBox horizontalSizedBoxXs = SizedBox(width: xs);
  static const SizedBox horizontalSizedBoxS = SizedBox(width: s);
  static const SizedBox horizontalSizedBoxM = SizedBox(width: m);
  static const SizedBox horizontalSizedBoxL = SizedBox(width: l);
  static const SizedBox horizontalSizedBoxXl = SizedBox(width: xl);
  static const SizedBox horizontalSizedBoxXxl = SizedBox(width: xxl);
}
