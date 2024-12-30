import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:udaadaa/models/message.dart';
import 'package:udaadaa/models/room.dart';
import 'package:udaadaa/utils/constant.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  List<Room> chatList = [];
  List<Message> messages = [];

  ChatCubit() : super(ChatInitial()) {
    loadChatList();
    loadInitialMessages();
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
      final ret =
          await supabase.from('messages').select("*").order('created_at');
      logger.d("getInitialMessages: $ret");
      messages = ret
          .map((e) => Message.fromMap(
                map: e,
                myUserId: supabase.auth.currentUser!.id,
              ))
          .toList();
      emit(ChatMessageLoaded());
    } catch (e) {
      logger.e("getInitialMessages error : $e");
    }
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
      final ret = await supabase.from('messages').upsert(message.toMap());
      logger.d("sendMessage: $ret");
      messages.add(message);
      emit(ChatMessageLoaded());
    } catch (e) {
      logger.e("sendMessage error: $e");
    }
  }

  List<Room> get getChatList => chatList;
  List<Message> get getMessages => messages;
}
