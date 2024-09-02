class Profile {
  Profile({
    required this.id,
    required this.nickname,
    this.createdAt,
    this.pushOption,
  });

  final String id;
  final String nickname;
  final DateTime? createdAt;
  final bool? pushOption;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nickname': nickname,
    };
  }

  Profile.fromMap({
    required Map<String, dynamic> map,
  })  : id = map['id'] as String,
        nickname = map['nickname'] as String,
        createdAt = DateTime.parse(map['created_at'] as String),
        pushOption = map['push_option'] as bool;

  Profile copyWith({
    String? id,
    String? nickname,
    DateTime? createdAt,
    bool? pushOption,
  }) {
    return Profile(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      createdAt: createdAt ?? this.createdAt,
      pushOption: pushOption ?? this.pushOption,
    );
  }
}
