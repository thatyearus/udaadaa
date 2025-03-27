part of 'chat_cubit.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

final class ChatListLoaded extends ChatState {}

final class ChatMessageLoaded extends ChatState {}

final class BlockUserFinished extends ChatState {}

final class ChatPushNotification extends ChatState {
  final String roomId, text;
  final Room roomInfo;

  ChatPushNotification(this.roomId, this.text, this.roomInfo);
}

final class ChatPushLoaded extends ChatState {}

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
