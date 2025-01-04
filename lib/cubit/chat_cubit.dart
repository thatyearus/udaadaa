import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udaadaa/models/chat_reaction.dart';
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
    setReactionListener();
    setReadReceiptListener();
  }

  Future<void> loadChatList() async {
    try {
      final ret = await supabase.from('rooms').select('*, profiles(*)');
      logger.d(ret);
      chatList = ret
          .map(
            (e) => Room.fromMap(
              e,
              members: (e['profiles'] as List<dynamic>)
                  .map((profileRet) => Profile.fromMap(map: profileRet))
                  .toList(),
            ),
          )
          .toList();
      logger.d("loadChatList: ${chatList[0].members}");
      logger.d("loadChatList: ${chatList[0].memberMap}");
      emit(ChatListLoaded());
    } catch (e) {
      logger.e("loadChatList error: $e");
    }
  }

  Future<void> loadInitialMessages() async {
    try {
      final ret = await supabase
          .from('messages')
          .select(
              "*, profiles!messages_user_id_fkey(*), chat_reactions(*), read_receipts(user_id)")
          .order('created_at');
      logger.d(ret);
      messages = ret
          .map(
            (e) => Message.fromMap(
              map: e,
              myUserId: supabase.auth.currentUser!.id,
              profile: Profile.fromMap(map: e['profiles']),
              reactions: (e['chat_reactions'] as List<dynamic>)
                  .map((reactionRet) => Reaction.fromMap(map: reactionRet))
                  .toList(),
              readReceipts: (e['read_receipts'] as List<dynamic>)
                  .map((receiptRet) => receiptRet['user_id'] as String)
                  .toSet(),
            ),
          )
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
                reactions: [],
                readReceipts: {},
              );
              logger.d("setMessagesListener: $message");
              messages = [message, ...messages];
              emit(ChatMessageLoaded());
            })
        .subscribe();
  }

  void setReactionListener() {
    supabase
        .channel('public:chat_reactions')
        .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'chat_reactions',
            callback: (payload) {
              final reaction = Reaction.fromMap(
                map: payload.newRecord,
              );
              /*
              messages = messages.map((message) {
                if (message.id == reaction.messageId) {
                  message.reactions = [reaction, ...message.reactions];
                }
                return message;
              }).toList();*/
              messages = List.from(messages.map((message) {
                if (message.id == reaction.messageId) {
                  message = message
                      .copyWith(reactions: [reaction, ...message.reactions]);
                }
                return message;
              }));
              logger.d("setReactionListener: $reaction");
              emit(ChatMessageLoaded());
            })
        .subscribe();
  }

  void setReadReceiptListener() {
    supabase
        .channel('public:read_receipts')
        .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'read_receipts',
            callback: (payload) {
              messages = List.from(messages.map((message) {
                if (message.id == payload.newRecord['message_id']) {
                  message = message.copyWith(readReceipts: {
                    ...message.readReceipts,
                    payload.newRecord['user_id'],
                  });
                }
                return message;
              }));
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
        reactions: [],
        readReceipts: {},
      );
      await supabase.from('messages').upsert(message.toMap());
    } catch (e) {
      logger.e("sendMessage error: $e");
    }
  }

  Room getRoom(String roomId) =>
      chatList.firstWhere((element) => element.id == roomId);

  Profile? getProfile(String roomId, String userId) =>
      getRoom(roomId).memberMap[userId]!;

  List<Room> get getChatList => chatList;
  List<Message> get getMessages => messages;
}
