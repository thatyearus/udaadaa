import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:udaadaa/models/room.dart';
import 'package:udaadaa/utils/constant.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  List<Room> chatList = [];

  ChatCubit() : super(ChatInitial()) {
    loadChatList();
  }

  Future<void> loadChatList() async {
    final ret = await supabase.from('rooms').select();
    logger.d("loadChatList: $ret");
    chatList = ret.map((e) => Room.fromMap(e)).toList();
    emit(ChatListLoaded());
  }

  List<Room> get getChatList => chatList;
}
