import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udaadaa/models/message.dart';
import 'package:udaadaa/models/profile.dart';
import 'package:udaadaa/models/room.dart';
import 'package:udaadaa/utils/constant.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  List<Room> chatList = [];
  List<Message> messages = [];

  ChatCubit() : super(ChatInitial()) {
    loadChatList();
    loadInitialMessages();
    setMessagesListener();
  }

  Future<void> loadChatList() async {
    try {
      final ret = await supabase.from('rooms').select();
      logger.d("loadChatList: $ret");
      chatList = ret.map((e) => Room.fromMap(e)).toList();
      emit(ChatListLoaded());
    } catch (e) {
      logger.e("loadChatList error: $e");
    }
  }

  Future<void> loadInitialMessages() async {
    try {
      final ret = await supabase
          .from('messages')
          .select("*, profiles!messages_user_id_fkey(*)")
          .order('created_at');
      logger.d("getInitialMessages: $ret");
      messages = ret
          .map((e) => Message.fromMap(
                map: e,
                myUserId: supabase.auth.currentUser!.id,
                profile: Profile.fromMap(map: e['profiles']),
              ))
          .toList();
      emit(ChatMessageLoaded());
    } catch (e) {
      logger.e("getInitialMessages error : $e");
    }
  }

  void setMessagesListener() {
    supabase
        .channel('public:messages')
        .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'messages',
            callback: (payload) async {
              final profileRet = await supabase
                  .from('profiles')
                  .select()
                  .eq('id', payload.newRecord['user_id'])
                  .single();
              final message = Message.fromMap(
                map: payload.newRecord,
                myUserId: supabase.auth.currentUser!.id,
                profile: Profile.fromMap(map: profileRet),
              );
              logger.d("setMessagesListener: $message");
              messages = [message, ...messages];
              emit(ChatMessageLoaded());
            })
        .subscribe();
  }

  Future<void> sendMessage(String content, String type, String roomId) async {
    try {
      final message = Message(
        roomId: roomId,
        userId: supabase.auth.currentUser!.id,
        content: content,
        type: type,
        isMine: true,
      );
      await supabase.from('messages').upsert(message.toMap());
    } catch (e) {
      logger.e("sendMessage error: $e");
    }
  }

  List<Room> get getChatList => chatList;
  List<Message> get getMessages => messages;
}
