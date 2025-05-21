import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/utils/recommended_calorie_calculator.dart';
import 'package:udaadaa/view/newonboarding/initial_view.dart';

class RecommendCalorieView extends StatefulWidget {
  const RecommendCalorieView({super.key});

  @override
  State<RecommendCalorieView> createState() => _RecommendCalorieViewState();
}

class _RecommendCalorieViewState extends State<RecommendCalorieView> {
  double? _recommendedCalorie;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateRecommendedCalorie();
  }

  void _calculateRecommendedCalorie() async {
    final profile = context.read<AuthCubit>().getCurProfile;
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    if (profile?.height == null || profile?.weight == null) return;

    setState(() {
      _recommendedCalorie = RecommendedCalorieCalculator.calculate(profile!);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                '권장 칼로리 섭취량',
                style: AppTextStyles.displayLarge(
                  const TextStyle(color: AppColors.black),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mifflin-St Jeor 방정식을 참고하여 계산했어요',
                style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                  color: AppColors.neutral[400],
                ),
              ),
              const SizedBox(height: 96),
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary[100]!.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.primary[50]!,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 8),
                              Text(
                                '${_recommendedCalorie!.round()}',
                                style: AppTextStyles.displayLarge(
                                  const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 48,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -1,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                              Text(
                                'kcal',
                                style: AppTextStyles.textTheme.titleLarge
                                    ?.copyWith(
                                  color: AppColors.primary[300],
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    '우다다는 급격한 다이어트보단\n지속적인, 그리고 다같이 하는 다이어트를 지향합니다',
                    style: AppTextStyles.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral[400],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const Spacer(),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InitialView(),
                      ),
                    );
                  },
                  child: Text(
                    "다음",
                    style: AppTextStyles.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
