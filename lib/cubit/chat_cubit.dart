import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udaadaa/models/chat_reaction.dart';
import 'package:udaadaa/models/message.dart';
import 'package:udaadaa/models/profile.dart';
import 'package:udaadaa/models/room.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  List<Room> chatList = [];
  Map<String, List<Message>> messages = {};
  Map<String, List<Message>> imageMessages = {};
  XFile? _selectedImage;

  ChatCubit() : super(ChatInitial()) {
    loadChatList().then((_) => fetchLatestMessages());
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

  Future<void> fetchLatestMessages() async {
    try {
      final updatedChatList = await Future.wait(
        chatList.map((room) async {
          final response = await supabase
              .from('messages')
              .select('*')
              .eq('room_id', room.id)
              .order('created_at', ascending: false)
              .limit(1)
              .single();

          final message = Message.fromMap(
            map: response,
            myUserId: supabase.auth.currentUser!.id,
            profile: room.memberMap[response['user_id']]!,
            reactions: [],
            readReceipts: {},
          );

          return room.copyWith(lastMessage: message); // 새로운 Room 객체 반환
        }),
      );

      chatList = updatedChatList;
      chatList.sort((a, b) =>
          b.lastMessage!.createdAt!.compareTo(a.lastMessage!.createdAt!));
      emit(ChatListLoaded());
    } catch (e) {
      logger.e('Error fetching latest messages: $e');
    }
  }

  Future<void> loadInitialMessages() async {
    try {
      final ret = await supabase
          .from('messages')
          .select(
              "*, profiles!messages_user_id_fkey(*), chat_reactions(*), read_receipts(user_id)")
          .order('created_at');
      // logger.d(ret);
      for (var row in ret) {
        final roomId = row['room_id'];
        if (!messages.containsKey(roomId)) {
          messages[roomId] = [];
        }
        messages[roomId]!.add(
          Message.fromMap(
            map: row,
            myUserId: supabase.auth.currentUser!.id,
            profile: Profile.fromMap(map: row['profiles']),
            reactions: (row['chat_reactions'] as List<dynamic>)
                .map((reactionRet) => Reaction.fromMap(map: reactionRet))
                .toList(),
            readReceipts: (row['read_receipts'] as List<dynamic>)
                .map((receiptRet) => receiptRet['user_id'] as String)
                .toSet(),
          ),
        );
      }
      /*
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
          .toList();*/
      emit(ChatMessageLoaded());
      for (var room in messages.keys) {
        for (var message in messages[room]!) {
          if (message.type == 'imageMessage') makeImageUrlMessage(message);
        }
        // if (message.type == 'imageMessage') makeImageUrlMessage(message);
      }
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
              if (message.type == 'imageMessage') makeImageUrlMessage(message);
              logger.d("setMessagesListener: $message");
              // messages = [message, ...messages];
              messages[message.roomId] = [
                message,
                ...messages[message.roomId]!
              ];
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
              messages[reaction.roomId] =
                  List.from(messages[reaction.roomId]!.map((message) {
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
              final roomId = payload.newRecord['room_id'];
              messages[roomId] = List.from(messages[roomId]!.map((message) {
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

  Future<void> selectImage(ImageSource pickertype) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: pickertype);

    if (pickedFile != null) {
      _selectedImage = pickedFile;
    }
  }

  Future<File?> compressImage(File file) async {
    try {
      final img.Image? image = img.decodeImage(file.readAsBytesSync());

      if (image == null) {
        throw Exception('Unable to decode image');
      }

      img.Image resizedImage = img.copyResize(image, width: 1024);

      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = tempDir.path;
      final File compressedImage =
          File('$tempPath/${DateTime.now().microsecondsSinceEpoch}.jpg')
            ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 70));

      return compressedImage;
    } catch (e) {
      Analytics().logEvent("업로드_압축실패", parameters: {"에러": e.toString()});
      logger.e(e);
      return null;
    }
  }

  Future<String?> uploadImage(String type, String roomId) async {
    final XFile? file = _selectedImage;
    if (file == null) {
      logger.e('No image selected');
      return null;
    }

    try {
      final File? compressedImage = await compressImage(File(file.path));
      if (compressedImage == null) {
        logger.e('Failed to compress image');
        return null;
      }
      final userId = supabase.auth.currentUser!.id;
      final imagePath =
          '$roomId/${DateTime.now().microsecondsSinceEpoch}_$userId.jpg';
      await supabase.storage
          .from('ImageMessages')
          .upload(imagePath, compressedImage);
      return imagePath;
    } catch (e) {
      logger.e(e);
      Analytics().logEvent("업로드_이미지실패", parameters: {"에러": e.toString()});
      return null;
    }
  }

  Future<void> sendImageMessage(String roomId) async {
    try {
      await selectImage(ImageSource.gallery);
      final imagePath = await uploadImage('imageMessage', roomId);
      if (imagePath == null) {
        logger.e('Failed to upload image');
        return;
      }
      final message = Message(
        roomId: roomId,
        userId: supabase.auth.currentUser!.id,
        imagePath: imagePath,
        type: 'imageMessage',
        isMine: true,
        reactions: [],
        readReceipts: {},
      );
      await supabase.from('messages').upsert(message.toMap());
    } catch (e) {
      logger.e("sendImageMessage error: $e");
    }
  }

  void makeImageUrlMessage(Message message) async {
    if (message.type == 'imageMessage' && message.imagePath != null) {
      try {
        // logger.d("makeImageUrl: ${message.imagePath}");
        final url = await supabase.storage
            .from('ImageMessages')
            .createSignedUrl(message.imagePath!, 3600);
        // logger.d("makeImageUrl: $url");
        messages[message.roomId] = List.from(messages[message.roomId]!.map((m) {
          if (m.id == message.id) {
            m = message.copyWith(imageUrl: url);
          }
          return m;
        }));
        if (!imageMessages.containsKey(message.roomId)) {
          imageMessages[message.roomId] = [];
        }
        imageMessages[message.roomId] = [
          message,
          ...imageMessages[message.roomId]!,
        ];
        emit(ChatMessageLoaded());
      } catch (e) {
        logger.e("makeImageUrl error: $e");
      }
    }
  }

  Room getRoom(String roomId) =>
      chatList.firstWhere((element) => element.id == roomId);

  Profile? getProfile(String roomId, String userId) =>
      getRoom(roomId).memberMap[userId]!;

  List<Message> getMessagesByRoomId(String roomId) => messages[roomId] ?? [];
  List<Message> getImageMessagesByRoomId(String roomId) =>
      imageMessages[roomId] ?? [];

  List<Room> get getChatList => chatList;
  Map<String, List<Message>> get getMessages => messages;
}
