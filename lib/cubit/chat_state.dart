part of 'chat_cubit.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

final class ChatListLoaded extends ChatState {}

final class ChatMessageLoaded extends ChatState {}

final class BlockUserFinished extends ChatState {}

final class ChatNotificationReceivedInForeground extends ChatState {
  final String roomId, title, body;
  final Room roomInfo;

  ChatNotificationReceivedInForeground(
      this.roomId, this.title, this.body, this.roomInfo);
}

class ChatPushOpenedFromBackground extends ChatState {
  final String roomId;
  final String text;
  final Room roomInfo;

  ChatPushOpenedFromBackground(this.roomId, this.text, this.roomInfo);
}

final class ChatPushLoaded extends ChatState {}

final class ChatMessagesRefreshedFromPush extends ChatState {
  final DateTime refreshedAt;

  ChatMessagesRefreshedFromPush() : refreshedAt = DateTime.now();
}

// 새롭게 추가한 상태 (안정적 갱신을 위해)
class UnreadMessagesUpdated extends ChatState {
  final int totalUnreadCount;
  final Map<String, int> unreadMessages;

  UnreadMessagesUpdated(this.totalUnreadCount, this.unreadMessages);
}

// 방 선태긍로가자
class JoinRoomLoading extends ChatState {}

class JoinRoomSuccess extends ChatState {}

class JoinRoomFailed extends ChatState {
  final String reason;
  JoinRoomFailed(this.reason);
}

class ChatImageSelected extends ChatState {} // ✅ 사진 선택됨

class ChatImageCleared extends ChatState {} // ✅ 사진 취소됨
