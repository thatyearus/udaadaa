class Report {
  Report({
    this.id,
    required this.userId,
    this.createdAt,
    required this.date,
    this.breakfast,
    this.lunch,
    this.dinner,
    this.snack,
    this.exercise,
    this.weight,
  });

  final String? id;
  final String userId;
  final DateTime? createdAt;
  final double? weight;
  final int? breakfast;
  final int? lunch;
  final int? dinner;
  final int? snack;
  final int? exercise;
  final DateTime date;

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['date'] = date.toIso8601String();

    // 선택적 필드
    if (id != null) data['id'] = id;
    if (createdAt != null) data['created_at'] = createdAt?.toIso8601String();
    if (weight != null) data['weight'] = weight;
    if (breakfast != null) data['breakfast'] = breakfast;
    if (lunch != null) data['lunch'] = lunch;
    if (dinner != null) data['dinner'] = dinner;
    if (snack != null) data['snack'] = snack;
    if (exercise != null) data['exercise'] = exercise;
    return data;
  }

  Report.fromMap({
    required Map<String, dynamic> map,
  })  : id = map['id'] as String?,
        userId = map['user_id'] as String,
        createdAt = map['created_at'] == null
            ? null
            : DateTime.parse(map['created_at'] as String),
        date = DateTime.parse(map['date'] as String),
        weight =
            map['weight'] == null ? null : (map['weight'] as num).toDouble(),
        breakfast = map['breakfast'] == null ? null : map['breakfast'] as int,
        lunch = map['lunch'] == null ? null : map['lunch'] as int,
        dinner = map['dinner'] == null ? null : map['dinner'] as int,
        snack = map['snack'] == null ? null : map['snack'] as int,
        exercise = map['exercise'] == null ? null : map['exercise'] as int;

  Report copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    DateTime? date,
    double? weight,
    int? breakfast,
    int? lunch,
    int? dinner,
    int? snack,
    int? exercise,
  }) {
    return Report(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      snack: snack ?? this.snack,
      exercise: exercise ?? this.exercise,
    );
  }
}
