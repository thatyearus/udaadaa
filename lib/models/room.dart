class Room {
  Room({
    required this.id,
    required this.createdAt,
    required this.roomName,
//    this.lastMessage,
  });

  final String id;
  final DateTime createdAt;
  final String roomName;
//  final Message? lastMessage;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.millisecondsSinceEpoch,
      'room_name': roomName,
    };
  }

  Room.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        roomName = map['room_name'],
        createdAt = DateTime.parse(map['created_at']);
//        lastMessage = null;

  Room copyWith({
    String? id,
    DateTime? createdAt,
    String? roomName,
//    Message? lastMessage,
  }) {
    return Room(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      roomName: roomName ?? this.roomName,
      //    lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}
