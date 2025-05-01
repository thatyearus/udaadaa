import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/challenge_cubit.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/result/result_view.dart';

class ResultListView extends StatelessWidget {
  const ResultListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('챌린지 참여 기록', style: AppTextStyles.textTheme.headlineMedium),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: context.read<ChallengeCubit>().fetchChallenge,
        child: BlocBuilder<ChallengeCubit, ChallengeState>(
          builder: (context, state) {
            if (state is ChallengeLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ChallengeList) {
              if (state.challenges.isEmpty) {
                return Center(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Text(
                      '챌린지 기록이 존재하지 없습니다.',
                      style: AppTextStyles.textTheme.bodyLarge,
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: state.challenges.length,
                itemBuilder: (context, index) {
                  final startDay =
                      '${state.challenges[index].startDay.year}.${state.challenges[index].startDay.month}.${state.challenges[index].startDay.day}';
                  final endDay =
                      '${state.challenges[index].endDay.year}.${state.challenges[index].endDay.month}.${state.challenges[index].endDay.day}';
                  return ListTile(
                    title: Text('챌린지 ${index + 1}',
                        style: AppTextStyles.textTheme.headlineSmall),
                    subtitle: Text('$startDay ~ $endDay'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      Analytics().logEvent(
                        "마이페이지_챌린지기록_상세",
                        parameters: {
                          "클릭": "챌린지 상세보기",
                          "챌린지번호": state.challenges[index].id ?? "",
                          "챌린지상태":
                              context.read<AuthCubit>().getChallengeStatus(),
                        },
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChallengeResultView(
                            isSuccess: state.challenges[index].isSuccess,
                            endDay: state.challenges[index].endDay,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }
            context.read<ChallengeCubit>().fetchChallenge();
            return Container();
          },
        ),
      ),
    );
  }
}
