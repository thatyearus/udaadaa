class Challenge {
  Challenge({
    this.id,
    required this.startDay,
    required this.endDay,
    required this.userId,
  });

  final int? id;
  final DateTime startDay;
  final DateTime endDay;
  final String userId;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'start_day': startDay.toIso8601String(),
      'end_day': endDay.toIso8601String(),
      'user_id': userId,
    };
  }

  Challenge.fromMap({
    required Map<String, dynamic> map,
  })  : id = map['id'] as int?,
        startDay = DateTime.parse(map['start_day'] as String),
        endDay = DateTime.parse(map['end_day'] as String),
        userId = map['user_id'] as String;

  Challenge copyWith({
    int? id,
    DateTime? startDay,
    DateTime? endDay,
    String? userId,
  }) {
    return Challenge(
      id: id ?? this.id,
      startDay: startDay ?? this.startDay,
      endDay: endDay ?? this.endDay,
      userId: userId ?? this.userId,
    );
  }
}
