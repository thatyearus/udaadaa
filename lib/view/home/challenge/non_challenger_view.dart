import 'package:flutter/material.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/view/onboarding/eighth_view.dart';

class NonChallengerView extends StatelessWidget {
  const NonChallengerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Analytics().logEvent(
            "홈_챌린지_참여하기",
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EighthView()),
          );
        },
        child: const Text('챌린지 참여하기'),
      ),
    );
  }
}
