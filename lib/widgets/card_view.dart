import 'package:flutter/material.dart';
import 'package:udaadaa/utils/constant.dart';

class CardView extends StatelessWidget {
  const CardView({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        shadowColor: AppColors.primary[100],
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.primary[100]!),
          borderRadius: BorderRadius.circular(10),
        ),
        surfaceTintColor: AppColors.primary[100],
        child: Padding(
          padding: AppSpacing.edgeInsetsL,
          child: child,
        ),
      ),
    );
  }
}

class CardView2 extends StatelessWidget {
  const CardView2({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 7,
            ),
          ],
        ),
        padding: EdgeInsets.only(
          top: 15,
          bottom: 55,
          left: 15,
          right: 0,
        ),
        child: child,
      ),
    );
  }
}
