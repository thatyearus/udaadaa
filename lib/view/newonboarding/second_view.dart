import 'package:flutter/material.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/newonboarding/third_view.dart';

class SecondView extends StatefulWidget {
  const SecondView({super.key});

  @override
  State<SecondView> createState() => _SecondViewState();
}

class _SecondViewState extends State<SecondView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("채팅방에서 미션을 인증\n할 수 있어요",
                    style: AppTextStyles.textTheme.displayMedium),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Image.asset(
                            'assets/certification-1.png',
                            height: 300,
                            fit: BoxFit.contain,
                          ),
                          Positioned(
                            bottom: -10,
                            right: -2,
                            child: _buildTapAnimationIcon(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Image.asset(
                        'assets/certification-2.png',
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const MissionVerificationList(),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
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
                      Analytics().logEvent(
                        "온보딩_세번째_뷰",
                        parameters: {"버튼": "클릭"},
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ThirdView(),
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
      ),
    );
  }

  Widget _buildTapAnimationIcon() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // 터치 효과 원형
            Container(
              width: 50 * _scaleAnimation.value,
              height: 50 * _scaleAnimation.value,
              decoration: BoxDecoration(
                color: AppColors.primary
                    .withOpacity(0.2 * _opacityAnimation.value),
                shape: BoxShape.circle,
              ),
            ),
            // 터치 아이콘
            Icon(
              Icons.touch_app,
              color: AppColors.primary,
              size: 30,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class MissionVerificationList extends StatelessWidget {
  const MissionVerificationList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        children: [
          _buildFeatureItem(
            "몸무게는 실시간 촬영만 가능해요",
            Icons.monitor_weight_rounded,
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            "식단은 사진으로 인증할 수 있어요",
            Icons.restaurant_rounded,
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            "운동은 자율적으로 업로드 해주세요",
            Icons.fitness_center_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        AppSpacing.horizontalSizedBoxM,
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
