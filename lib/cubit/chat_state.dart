part of 'chat_cubit.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

final class ChatListLoaded extends ChatState {}

final class ChatMessageLoaded extends ChatState {}
