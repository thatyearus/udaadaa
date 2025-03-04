class Profile {
  Profile({
    required this.id,
    required this.nickname,
    this.createdAt,
    this.pushOption,
    this.fcmToken,
  });

  final String id;
  final String nickname;
  final DateTime? createdAt;
  final bool? pushOption;
  final String? fcmToken;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nickname': nickname,
      'fcm_token': fcmToken,
      'push_option': pushOption,
    };
  }

  Profile.fromMap({
    required Map<String, dynamic> map,
  })  : id = map['id'] as String,
        nickname = map['nickname'] as String,
        createdAt = DateTime.parse(map['created_at'] as String),
        pushOption = map['push_option'] as bool,
        fcmToken = map['fcm_token'] as String?;

  Profile copyWith({
    String? id,
    String? nickname,
    DateTime? createdAt,
    bool? pushOption,
    String? fcmToken,
  }) {
    return Profile(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      createdAt: createdAt ?? this.createdAt,
      pushOption: pushOption ?? this.pushOption,
      fcmToken: fcmToken == "" ? null : fcmToken ?? this.fcmToken,
    );
  }
}
