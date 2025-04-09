import 'package:udaadaa/models/message.dart';
import 'package:udaadaa/models/profile.dart';

class Room {
  Room({
    required this.id,
    required this.createdAt,
    required this.roomName,
    required this.members,
    this.startDay,
    this.endDay,
    this.memberMap = const {},
    this.lastMessage,
  });

  final String id;
  final DateTime createdAt;
  final String roomName;
  final DateTime? startDay, endDay;
  List<Profile> members = [];
  Map<String, Profile> memberMap = {};
  final Message? lastMessage;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.millisecondsSinceEpoch,
      'room_name': roomName,
    };
  }

  // Room.fromMap(Map<String, dynamic> map, {required this.members})
  //     : id = map['id'],
  //       roomName = map['room_name'],
  //       createdAt = DateTime.parse(map['created_at']),
  //       memberMap = {for (var member in members) member.id: member},
  //       lastMessage = null,
  //       startDay =
  //           map['start_day'] != null ? DateTime.parse(map['start_day']) : null,
  //       endDay = map['end_day'] != null ? DateTime.parse(map['end_day']) : null;

  Room.fromMap(
    Map<String, dynamic> map, {
    required this.members,
    this.lastMessage,
  })  : id = map['id'],
        roomName = map['room_name'],
        createdAt = DateTime.parse(map['created_at']),
        memberMap = {
          for (var member in members) member.id: member
        }, // ✅ 선택적으로 할당
        startDay =
            map['start_day'] != null ? DateTime.parse(map['start_day']) : null,
        endDay = map['end_day'] != null ? DateTime.parse(map['end_day']) : null;

  Room copyWith({
    String? id,
    DateTime? createdAt,
    String? roomName,
    List<Profile>? members,
    Map<String, Profile>? memberMap,
    Message? lastMessage,
    DateTime? startDay,
    DateTime? endDay,
  }) {
    return Room(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      roomName: roomName ?? this.roomName,
      members: members ?? this.members,
      memberMap: memberMap ?? this.memberMap,
      lastMessage: lastMessage ?? this.lastMessage,
      startDay: startDay ?? this.startDay,
      endDay: endDay ?? this.endDay,
    );
  }
}
