import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/detail/my_record_view.dart';
import 'package:udaadaa/view/detail/record_view.dart';
import 'package:udaadaa/view/home/report_view.dart';
import 'package:udaadaa/widgets/fab.dart';
import 'package:udaadaa/widgets/report_summary.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          return context.read<ProfileCubit>().getMyTodayReport();
        },
        child: Column(children: [
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
            child: const ReportSummary(),
          ),
          AppSpacing.verticalSizedBoxL,
          Expanded(
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return GridTile(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const RecordView()));
                      },
                      child: Container(
                        color: AppColors.neutral[100],
                        child: Center(
                          child: Text('Item $index'),
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ]),
      ),
      floatingActionButton: const AddFabButton(),
    );
  }
}
