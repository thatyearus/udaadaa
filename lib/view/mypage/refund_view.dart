import 'package:flutter/material.dart';
import 'package:udaadaa/utils/constant.dart';

class RefundView extends StatelessWidget {
  const RefundView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('상금규정', style: AppTextStyles.textTheme.headlineLarge),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '상금은 2주가 끝나는 시점을 기준으로 진행됩니다',
                style: AppTextStyles.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildRefundTable(),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Text(
                '선택한 챌린지에 실패하면 상금은 0원입니다',
                style: AppTextStyles.textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            _buildRefundConditions(),
            const SizedBox(height: AppSpacing.xxl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '*챌린지 마지막 날이 기준이니 마지막 날 꼭 인증을 해주셔야 합니다',
                    style: AppTextStyles.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefundTable() {
    return Table(
      border: TableBorder.all(
        color: AppColors.neutral[200]!,
        width: 1,
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: AppColors.neutral[200],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Text(
                '인증 횟수',
                style: AppTextStyles.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Text(
                '상금',
                style: AppTextStyles.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        _buildTableRow('7번 이하', '0원'),
        _buildTableRow('8번 ~ 9번', '5,000원'),
        _buildTableRow('10번 ~ 11번', '15,000원'),
        _buildTableRow('12번 - 13번', '25,000원'),
        _buildTableRow('14번', '30,000원'),
      ],
    );
  }

  TableRow _buildTableRow(String count, String amount) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Text(
            count,
            style: AppTextStyles.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Text(
            amount,
            style: AppTextStyles.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildRefundConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '- ',
              style: AppTextStyles.textTheme.bodyLarge,
            ),
            Expanded(
              child: Text(
                '1kg 감량 챌린지는 1kg 이상 감량',
                style: AppTextStyles.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '- ',
              style: AppTextStyles.textTheme.bodyLarge,
            ),
            Expanded(
              child: Text(
                '0kg 유지 챌린지는 0kg 이하 증량',
                style: AppTextStyles.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
