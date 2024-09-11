import 'package:udaadaa/models/profile.dart';

enum ReactionType {
  good,
  cheerup,
  hmmm,
  nope,
  awesome,
}

class Reaction {
  Reaction({
    this.id,
    required this.userId,
    this.createdAt,
    required this.feedId,
    required this.type,
    this.profile,
  });

  final String? id;
  final String userId;
  final DateTime? createdAt;
  final String feedId;
  final ReactionType type;
  final Profile? profile;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user_id': userId,
      'type': type.name,
      'feed_id': feedId,
    };
  }

  Reaction.fromMap({
    required Map<String, dynamic> map,
  })  : id = map['id'] as String,
        userId = map['user_id'] as String,
        createdAt = DateTime.parse(map['created_at'] as String),
        type = ReactionType.values.firstWhere((e) => e.name == map['type']),
        feedId = map['feed_id'] as String,
        profile = map['profiles'] != null
            ? Profile.fromMap(map: map['profiles'] as Map<String, dynamic>)
            : null;

  Reaction copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    String? feedId,
    ReactionType? type,
  }) {
    return Reaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      feedId: feedId ?? this.feedId,
      type: type ?? this.type,
    );
  }
}
