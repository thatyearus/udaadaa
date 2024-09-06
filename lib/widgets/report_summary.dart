import 'package:flutter/material.dart';
import 'package:udaadaa/utils/constant.dart';

class ReportSummary extends StatelessWidget {
  const ReportSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutral[100],
      padding: AppSpacing.edgeInsetsM,
      width: double.infinity,
      alignment: Alignment.center,
      child: const Text("리포트 요약"),
    );
  }
}
