class Calorie {
  final int totalCalories;
  final List<String> items;
  final String aiText;

  Calorie({
    required this.totalCalories,
    required this.items,
    required this.aiText,
  });

  factory Calorie.fromJson(Map<String, dynamic> json) {
    return Calorie(
      totalCalories: json['total_calories'] as int,
      items: (json['items'] as String)
          .split(',')
          .map((item) => item.trim())
          .toList(),
      aiText: json['ai_text'] as String,
    );
  }
}
