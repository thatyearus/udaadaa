import 'dart:typed_data';

DateTime convertToKst(DateTime utcTime) {
  return utcTime.toUtc().add(const Duration(hours: 9));
}

class Message {
  Message({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.content,
    required this.type,
    // required this.profile,
    required this.createdAt,
    required this.isMine,
    required this.imagePath,
    // required this.reactions,
    // required this.readReceipts,
    this.image,
    this.imageUrl,
  });

  final String id;
  final String userId;
  final String roomId;
  final String? content;
  final String type;
  // final Profile profile;
  final DateTime createdAt;
  final bool isMine;
  final Uint8List? image;
  final String? imagePath;
  // final List<Reaction> reactions;
  // final Set<String> readRecefipts;
  String? imageUrl;

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'room_id': roomId,
      'content': content,
      'image_path': imagePath,
      'type': type,
    };
  }

  Message.fromMap({
    required Map<String, dynamic> map,
    required String myUserId,
    // required this.reactions,
    // required this.readReceipts,
    // required this.profile,
    this.image,
    this.imageUrl,
  })  : id = map['id'],
        roomId = map['room_id'],
        userId = map['user_id'],
        content = map['content'],
        imagePath = map['image_path'],
        createdAt = convertToKst(DateTime.parse(map['created_at'])),
        type = map['type'],
        isMine = map['user_id'] == myUserId;

  Message copyWith({
    String? id,
    String? userId,
    String? roomId,
    String? text,
    String? type,
    // Profile? profile,
    DateTime? createdAt,
    bool? isMine,
    // List<Reaction>? reactions,
    // Set<String>? readReceipts,
    Uint8List? image,
    String? imageUrl,
    String? imagePath,
  }) {
    return Message(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      roomId: roomId ?? this.roomId,
      content: text ?? content,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      // profile: profile ?? this.profile,
      isMine: isMine ?? this.isMine,
      // reactions: reactions ?? this.reactions,
      // readReceipts: readReceipts ?? this.readReceipts,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
