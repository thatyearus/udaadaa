class Profile {
  Profile({
    required this.id,
    required this.nickname,
    this.createdAt,
    this.pushOption,
    this.fcmToken,
    this.height,
    this.weight,
  });

  final String id;
  final String nickname;
  final DateTime? createdAt;
  final bool? pushOption;
  final String? fcmToken;
  final double? height;
  final double? weight;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nickname': nickname,
      'fcm_token': fcmToken,
      'push_option': pushOption,
      'height': height,
      'weight': weight,
    };
  }

  Profile.fromMap({
    required Map<String, dynamic> map,
  })  : id = map['id'] as String,
        nickname = map['nickname'] as String,
        createdAt = DateTime.parse(map['created_at'] as String),
        pushOption = map['push_option'] as bool,
        fcmToken = map['fcm_token'] as String?,
        height =
            map['height'] != null ? (map['height'] as num).toDouble() : null,
        weight =
            map['weight'] != null ? (map['weight'] as num).toDouble() : null;

  Profile copyWith({
    String? id,
    String? nickname,
    DateTime? createdAt,
    bool? pushOption,
    String? fcmToken,
    double? height,
    double? weight,
  }) {
    return Profile(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      createdAt: createdAt ?? this.createdAt,
      pushOption: pushOption ?? this.pushOption,
      fcmToken: fcmToken == "" ? null : fcmToken ?? this.fcmToken,
      height: height ?? this.height,
      weight: weight ?? this.weight,
    );
  }
}
