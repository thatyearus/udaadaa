class Reaction {
  Reaction({
    this.id,
    required this.roomId,
    required this.userId,
    required this.messageId,
    required this.content,
    this.createdAt,
  });

  final String? id;
  final String userId;
  final String roomId;
  final String content;
  final String messageId;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'room_id': roomId,
      'message_id': messageId,
      'content': content,
    };
  }

  Reaction.fromMap({
    required Map<String, dynamic> map,
  })  : id = map['id'],
        roomId = map['room_id'],
        userId = map['user_id'],
        messageId = map['message_id'],
        content = map['content'],
        createdAt = DateTime.parse(map['created_at']);

  Reaction copyWith({
    String? id,
    String? userId,
    String? roomId,
    String? content,
    String? messageId,
    DateTime? createdAt,
  }) {
    return Reaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      roomId: roomId ?? this.roomId,
      messageId: messageId ?? this.messageId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
