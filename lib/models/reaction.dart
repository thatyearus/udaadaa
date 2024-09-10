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
  });

  final String? id;
  final String userId;
  final DateTime? createdAt;
  final String feedId;
  final ReactionType type;

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
        type = map['type'] as ReactionType,
        feedId = map['feed_id'] as String;

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
