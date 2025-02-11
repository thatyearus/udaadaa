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
