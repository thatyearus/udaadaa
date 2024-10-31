class Weight {
  Weight({
    this.id,
    required this.userId,
    this.createdAt,
    required this.date,
    required this.weight,
    required this.imagePath,
  });

  final String? id;
  final String userId;
  final DateTime? createdAt;
  final DateTime date;
  final double weight;
  final String imagePath;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user_id': userId,
      'date': date.toIso8601String(),
      'weight': weight,
      'image_path': imagePath,
    };
  }

  Weight.fromMap({
    required Map<String, dynamic> map,
  })  : id = map['id'] as String,
        userId = map['user_id'] as String,
        createdAt = DateTime.parse(map['created_at'] as String),
        date = DateTime.parse(map['date'] as String),
        weight = map['weight'] as double,
        imagePath = map['image_path'] as String;

  Weight copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    DateTime? date,
    double? weight,
    String? imagePath,
  }) {
    return Weight(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
