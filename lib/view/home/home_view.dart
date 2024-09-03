import 'package:flutter/material.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/detail/my_record_view.dart';
import 'package:udaadaa/view/home/report_view.dart';
import 'package:udaadaa/widgets/fab.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyRecordView(),
              ),
            );
          },
          child: Container(
            color: AppColors.neutral[100],
            padding: AppSpacing.edgeInsetsM,
            width: double.infinity,
            alignment: Alignment.center,
            child: const Text("내 최근 기록"),
          ),
        ),
        AppSpacing.verticalSizedBoxXl,
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReportView(),
              ),
            );
          },
          child: Container(
            color: AppColors.neutral[100],
            padding: AppSpacing.edgeInsetsM,
            width: double.infinity,
            alignment: Alignment.center,
            child: const Text("리포트뷰"),
          ),
        ),
      ]),
      floatingActionButton: const AddFabButton(),
    );
  }
}
