import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udaadaa/cubit/form_cubit.dart';
import 'package:udaadaa/models/calorie.dart';
import 'package:udaadaa/models/chat_reaction.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/models/message.dart';
import 'package:udaadaa/models/profile.dart';
import 'package:udaadaa/models/room.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  FormCubit formCubit;
  List<Room> chatList = [];
  Map<String, List<Message>> messages = {};
  // Map<String, List<Message>> imageMessages = {};
  Map<String, DateTime?> readReceipts = {};
  XFile? _selectedImage;
  String? currentRoomId;
  List<String> blockedUsers = [];
  List<String> blockedMessages = [];

  ChatCubit(this.formCubit) : super(ChatInitial()) {
    loadChatList().then((_) {
      fetchLatestMessages();
      fetchLatestReceipt();
    });
    Future.wait([
      fetchBlockedUsers(),
      fetchBlockedMessages(),
    ]).then(
      (value) {
        loadInitialMessages();
        setMessagesListener();
        setReactionListener();
        setReadReceiptListener();
      },
    );
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

  Future<void> fetchLatestReceipt() async {
    try {
      final futures = chatList.map((room) async {
        final response = await supabase
            .from('read_receipts')
            .select('created_at')
            .eq('room_id', room.id)
            .eq('user_id', supabase.auth.currentUser!.id)
            .order('created_at', ascending: false)
            .limit(1);
        if (response.isNotEmpty) {
          if (readReceipts[room.id] == null ||
              readReceipts[room.id]!.isBefore(response[0]['created_at'])) {
            readReceipts[room.id] = DateTime.parse(response[0]['created_at'])
                .add(const Duration(hours: 9));
          }
        }
      });
      await Future.wait(futures);
      for (var room in chatList) {
        logger.d("fetchLatestReceipt: ${room.id} ${readReceipts[room.id]}");
      }
    } catch (e) {
      logger.e('Error fetching latest read receipts: $e');
    }
  }

  Future<void> fetchBlockedUsers() async {
    try {
      final response = await supabase
          .from('blocked_users')
          .select('block_user_id')
          .eq('user_id', supabase.auth.currentUser!.id);
      blockedUsers = response.map((e) => e['block_user_id'] as String).toList();
      logger.d("fetchBlockedUsers: $blockedUsers");
    } catch (e) {
      logger.e('Error fetching blocked users: $e');
    }
  }

  Future<void> fetchBlockedMessages() async {
    try {
      final response = await supabase
          .from('blocked_messages')
          .select('message_id')
          .eq('user_id', supabase.auth.currentUser!.id);
      blockedMessages = response.map((e) => e['message_id'] as String).toList();
      logger.d("fetchBlockedMessages: $blockedMessages");
    } catch (e) {
      logger.e('Error fetching blocked messages: $e');
    }
  }

  Future<void> loadInitialMessages() async {
    try {
      final ret = await supabase
          .from('messages')
          .select(
              "*, profiles!messages_user_id_fkey(*), chat_reactions(*), read_receipts(user_id)")
          .not('user_id', 'in', blockedUsers)
          .not('id', 'in', blockedMessages)
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
          if (message.imagePath != null) makeImageUrlMessage(message);
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
              if (blockedUsers.contains(payload.newRecord['user_id'])) return;
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
              if (message.imagePath != null) makeImageUrlMessage(message);
              logger.d("setMessagesListener: $message");
              // messages = [message, ...messages];
              final updatedChatList = List<Room>.from(chatList);
              final roomIndex = updatedChatList
                  .indexWhere((room) => room.id == message.roomId);

              if (roomIndex != -1) {
                updatedChatList[roomIndex] =
                    updatedChatList[roomIndex].copyWith(
                  lastMessage: message,
                );
              }
              chatList = updatedChatList;
              chatList.sort((a, b) => b.lastMessage!.createdAt!
                  .compareTo(a.lastMessage!.createdAt!));

              if (!messages.containsKey(message.roomId)) {
                messages[message.roomId] = [];
              }
              messages[message.roomId] = [
                message,
                ...messages[message.roomId]!
              ];
              if (message.roomId == currentRoomId) {
                sendReadReceipt(message.roomId, message.id!);
              }
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

  Future<void> enterRoom(String roomId) async {
    try {
      currentRoomId = roomId;
      final unreadMessages = messages[roomId]!
          .where((message) =>
              message.createdAt != null &&
              (readReceipts[roomId] == null ||
                  message.createdAt!.isAfter(readReceipts[roomId]!)))
          .toList();
      logger.d("readReceipts: ${readReceipts[roomId]}");
      logger.d("enterRoom: $unreadMessages");
      final readReceiptsMap = unreadMessages
          .map((message) => {
                'room_id': roomId,
                'message_id': message.id,
                'user_id': supabase.auth.currentUser!.id,
              })
          .toList();
      if (readReceiptsMap.isEmpty) return;
      await supabase.from('read_receipts').upsert(readReceiptsMap);
      readReceipts[roomId] = unreadMessages.isNotEmpty
          ? unreadMessages.first.createdAt
          : DateTime.now();
    } catch (e) {
      logger.e("enterRoom error: $e");
    }
  }

  void leaveRoom(String roomId) {
    logger.d("leaveRoom: $roomId");
    currentRoomId = null;
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

  Future<String?> uploadImage(String roomId, XFile? otherFile) async {
    final XFile? file = otherFile ?? _selectedImage;
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
      final imagePath = await uploadImage(roomId, null);
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
    if (message.imagePath != null) {
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
        /*
        if (!imageMessages.containsKey(message.roomId)) {
          imageMessages[message.roomId] = [];
        }
        imageMessages[message.roomId] = [
          message,
          ...imageMessages[message.roomId]!,
        ];*/
        emit(ChatMessageLoaded());
      } catch (e) {
        logger.e("makeImageUrl error: $e");
      }
    }
  }

  void sendReadReceipt(String roomId, String messageId) async {
    try {
      logger.d("sendReadReceipt: $roomId $messageId");
      await supabase.from('read_receipts').upsert({
        'room_id': roomId,
        'message_id': messageId,
        'user_id': supabase.auth.currentUser!.id,
      });
      readReceipts[roomId] = DateTime.now().add(const Duration(hours: 9));
    } catch (e) {
      logger.e("sendReadReceipt error: $e");
    }
  }

  void sendReaction(String roomId, String messageId, String emoji) async {
    try {
      Reaction reaction = Reaction(
        roomId: roomId,
        messageId: messageId,
        userId: supabase.auth.currentUser!.id,
        content: emoji,
      );
      await supabase.from('chat_reactions').upsert(reaction.toMap());
      /*await supabase.from('chat_reactions').upsert({
        'room_id': roomId,
        'message_id': messageId,
        'user_id': supabase.auth.currentUser!.id,
        'emoji': emoji,
      });*/
    } catch (e) {
      logger.e("sendReaction error: $e");
    }
  }

  void blockUser(String userId) async {
    try {
      await supabase.from('blocked_users').upsert({
        'block_user_id': userId,
        'user_id': supabase.auth.currentUser!.id,
      });
      blockedUsers.add(userId);
      logger.d("blockUser: $userId");
    } catch (e) {
      logger.e("blockUser error: $e");
    }
  }

  void missionComplete({
    required FeedType type,
    required String review,
    String? weight,
    String? exerciseTime,
    String? mealContent,
    Calorie? calorie,
    required String contentType,
  }) async {
    if (currentRoomId == null) return;
    final userId = supabase.auth.currentUser!.id;
    /*
  // 인증 데이터
  final feedData = {
    'user_id': userId,
    'review': content,
    'image_path': imageUrl,
    'type': 'certification',
  };*/
    final [imagePath, feedData] = await Future.wait([
      uploadImage(currentRoomId!, formCubit.selectedImages['FOOD']),
      formCubit.feedInfo(
        type: type,
        review: review,
        contentType: contentType,
        calorie: calorie,
        mealContent: mealContent,
      ),
    ]);
    if (imagePath == null) {
      logger.e('Failed to upload image');
      return;
    }
    feedData['type'] = (feedData['type'] as FeedType).name;

    /*final feedData = await formCubit.feedInfo(
      type: type,
      review: review,
      contentType: contentType,
      calorie: calorie,
      mealContent: mealContent,
    );*/

    logger.d(feedData);
    // 채팅 메시지 데이터
    final messageData = {
      'room_id': currentRoomId,
      'user_id': userId,
      'image_path': imagePath,
      'content': mealContent,
      'type': 'missionMessage',
    };
    logger.d(messageData);

    try {
      // 트랜잭션 실행
      final feedId = await supabase.rpc('mission_complete', params: {
        'user_id': userId,
        'review': feedData['review'],
        'feed_type': feedData['type'],
        'feed_image_path': feedData['image_path'],
        'calorie': feedData['calorie'],
        'room_id': messageData['room_id'],
        'content': messageData['content'],
        'message_image_path': messageData['image_path'],
        'message_type': messageData['type'],
      });
      formCubit.missionComplete(
          type: type, review: review, contentType: contentType, feedId: feedId);
      logger.d('Certification uploaded successfully!');
    } catch (e) {
      logger.e('Error uploading certification: $e');
    }
  }

  Room getRoom(String roomId) =>
      chatList.firstWhere((element) => element.id == roomId);

  Profile? getProfile(String roomId, String userId) =>
      getRoom(roomId).memberMap[userId];

  List<Message> getMessagesByRoomId(String roomId) => messages[roomId] ?? [];
  /* List<Message> getImageMessagesByRoomId(String roomId) =>
      imageMessages[roomId] ?? [];*/

  List<Room> get getChatList => chatList;
  Map<String, List<Message>> get getMessages => messages;
}
