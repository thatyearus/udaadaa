import 'package:flutter/material.dart';
import 'package:udaadaa/service/notifications/notification_service.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/newonboarding/second_view.dart';

class FirstView extends StatelessWidget {
  const FirstView({super.key});

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
                Text("챌린지 참여를 위해\n코드를 입력해주세요",
                    style: AppTextStyles.textTheme.displayMedium),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/code1.png',
                        height: 240,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  "참여 코드를 입력하면 채팅방이 생겨요",
                  style: AppTextStyles.textTheme.headlineMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                const ChatRoomFeaturesList(),
                const SizedBox(height: 60),
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
                        "온보딩_두번째_뷰",
                        parameters: {"버튼": "클릭"},
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SecondView(),
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
}

class ChatRoomFeaturesList extends StatelessWidget {
  const ChatRoomFeaturesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                "2주 동안 채팅방에서 챌린지를 진행해요",
                Icons.calendar_month_rounded,
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                "채팅방에서 다른 사람과 함께 다이어트를 해보세요",
                Icons.people_alt_rounded,
              ),
            ],
          ),
        ),
      ],
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
