class Challenge {
  Challenge({
    this.id,
    required this.startDay,
    required this.endDay,
    required this.userId,
    required this.isSuccess,
  });

  final String? id;
  final DateTime startDay;
  final DateTime endDay;
  final String userId;
  final bool isSuccess;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'start_day': startDay.toIso8601String(),
      'end_day': endDay.toIso8601String(),
      'user_id': userId,
      'is_success': isSuccess,
    };
  }

  Challenge.fromMap({
    required Map<String, dynamic> map,
  })  : id = map['id'] as String?,
        startDay = DateTime.parse(map['start_day'] as String),
        endDay = DateTime.parse(map['end_day'] as String),
        userId = map['user_id'] as String,
        isSuccess = map['is_success'] as bool;

  Challenge copyWith({
    String? id,
    DateTime? startDay,
    DateTime? endDay,
    String? userId,
    bool? isSuccess,
  }) {
    return Challenge(
      id: id ?? this.id,
      startDay: startDay ?? this.startDay,
      endDay: endDay ?? this.endDay,
      userId: userId ?? this.userId,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
