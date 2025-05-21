import 'package:udaadaa/models/profile.dart';

/// 권장 칼로리 계산을 위한 유틸리티 클래스
class RecommendedCalorieCalculator {
  /// Mifflin-St Jeor 방정식을 사용하여 권장 칼로리를 계산합니다.
  ///
  /// [profile] 사용자의 프로필 정보 (키, 체중 필요)
  ///
  /// Returns 권장 칼로리 (kcal)
  static double calculate(Profile profile) {
    if (profile.height == null || profile.weight == null) {
      return 1300;
    }

    // BMR 계산 (Mifflin-St Jeor 방정식)
    final bmr =
        (10 * profile.weight!) + (6.25 * profile.height!) - (5 * 30) - 161;

    // 총 에너지 소비량 계산 (1.2 곱하기)
    final tdee = bmr * 1.2;

    // 권장 섭취량 계산 (310 감소)
    return tdee - 310;
  }
}
