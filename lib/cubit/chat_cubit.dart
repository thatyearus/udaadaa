import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/challenge_cubit.dart';
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
  ChallengeCubit challengeCubit;
  List<Room> chatList = [];
  Map<String, List<Message>> messages = {};
  // Map<String, List<Message>> imageMessages = {};
  Map<String, DateTime?> readReceipts = {};
  XFile? _selectedImage;
  String? currentRoomId;
  List<String> blockedUsers = [];
  List<String> blockedMessages = [];
  Map<String, int> unreadMessages = {};
  int unreadMessageCount = 0;
  List<MapEntry<Profile, double>> ranking = [];
  double weightAverage = 0.0;
  Map<String, bool> _pushOptions = {};
  bool _initialized = false;
  bool wasPushHandled = false;

  final AuthCubit authCubit;
  late final StreamSubscription authSubscription;

  RealtimeChannel? _messageChannel;
  RealtimeChannel? _reactionChannel;
  RealtimeChannel? _readReceiptChannel;

  ChatCubit(this.authCubit, this.formCubit, this.challengeCubit)
      : super(ChatInitial()) {
    if (authCubit.state is Authenticated) {
      _initialize();
    }

    authSubscription = authCubit.stream.listen((authState) {
      if (authState is Authenticated) {
        _initialize();
      }
    });
  }

  // ChatCubit(this.formCubit, this.challengeCubit) : super(ChatInitial()) {
  //   Future.wait([
  //     fetchBlockedUsers(),
  //     fetchBlockedMessages(),
  //   ]).then(
  //     (value) {
  //       Future.wait([
  //         fetchPushOptions(),
  //         loadChatList().then((_) async {
  //           fetchLatestMessages();
  //           await fetchLatestReceipt();
  //           FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //             if (message.data['roomId'] != null) {
  //               final roomId = message.data['roomId'];
  //               final roomInfo =
  //                   chatList.firstWhere((room) => room.id == roomId);
  //               emit(ChatPushNotification(roomId, "새로운 메시지가 도착했습니다", roomInfo));
  //             }
  //           });
  //         }).catchError((e) {
  //           logger.e("loadChatList error: $e");
  //         }),
  //         loadInitialMessages(),
  //       ]).then((_) {
  //         calculateUnreadMessages();
  //         _initialized = true;
  //       }).catchError((e) {
  //         logger.e("loadInitialMessages error: $e");
  //       });
  //       setMessagesListener();
  //       setReactionListener();
  //       setReadReceiptListener();
  //     },
  //   ).catchError((e) {
  //     logger.e("fetchBlockedUsers error: $e");
  //   });
  // }

  Future<void> _initialize() async {
    Future.wait([
      fetchBlockedUsers(),
      fetchBlockedMessages(),
    ]).then(
      (value) {
        Future.wait([
          fetchPushOptions(),
          loadChatList().then((_) async {
            fetchLatestMessages();
            await fetchLatestReceipt();
            FirebaseMessaging.onMessage.listen((RemoteMessage message) {
              if (message.data['roomId'] != null) {
                final roomId = message.data['roomId'];
                final roomInfo =
                    chatList.firstWhere((room) => room.id == roomId);
                emit(ChatNotificationReceivedInForeground(
                  roomId,
                  message.notification?.title ?? '채팅방 알림', // title
                  message.notification?.body ?? '새로운 메시지가 도착했습니다', // body
                  roomInfo,
                ));
              }
            });
            FirebaseMessaging.onMessageOpenedApp
                .listen((RemoteMessage message) {
              initializeAndEnterFromPush(message);
            });
          }).catchError((e) {
            logger.e("loadChatList error: $e");
          }),
          loadInitialMessages(),
        ]).then((_) {
          calculateUnreadMessages();
        }).catchError((e) {
          logger.e("loadInitialMessages error: $e");
        });
        setMessagesListener();
        setReactionListener();
        setReadReceiptListener();
      },
    ).catchError((e) {
      logger.e("fetchBlockedUsers error: $e");
    });
    _initialized = true;
  }

  Future<void> initializeAndEnterFromPush(RemoteMessage message) async {
    wasPushHandled = true;
    await Future.delayed(Duration(milliseconds: 500));
    debugPrint("⏰ 0.5초 딜레이 끝!");
    // await loadChatList();
    // await fetchLatestMessages();
    // await fetchLatestReceipt();
    await refreshAllMessagesForPush();
    if (message.data['roomId'] != null) {
      final roomId = message.data['roomId'];
      final roomInfo = chatList.firstWhere((room) => room.id == roomId);

      // ✅ 메시지 디버깅 출력 (최대 20개)
      final messageList = messages[roomId];

      if (messageList == null) {
        logger.d("📭 messages[$roomId]가 비어있습니다.");
      } else {
        final limitedMessages = messageList.take(20).toList();
        logger.d("📦 총 ${messageList.length}개의 메시지 중 최대 20개 출력:");

        for (int i = 0; i < limitedMessages.length; i++) {
          final m = limitedMessages[i];
          logger.d(
              "[$i] 📨 messageId: ${m.id}, content: ${m.content}, createdAt: ${m.createdAt}, sender: ${m.userId}");
        }
      }
      calculateUnreadMessages();
      // 기존 emit 유지
      emit(ChatPushOpenedFromBackground(
        roomId,
        "알림을 클릭하여 들어왔습니다.",
        roomInfo,
      ));
    }
  }

  Future<void> refreshAllMessagesForPush() async {
    try {
      // 1️⃣ 기존 모든 메시지 초기화
      messages.clear();

      await loadChatList();
      await fetchLatestMessages();
      await fetchLatestReceipt();

      // 2️⃣ Supabase에서 전체 메시지 조회 (block 대상 제외)
      final ret = await supabase
          .from('messages')
          .select(
              "*, profiles!messages_user_id_fkey(*), chat_reactions(*), read_receipts(user_id)")
          .not('user_id', 'in', blockedUsers)
          .not('id', 'in', blockedMessages)
          .order('created_at');

      // 3️⃣ messages 맵에 roomId 기준으로 분류하여 추가
      for (var row in ret) {
        final roomId = row['room_id'];
        messages.putIfAbsent(roomId, () => []);

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

      // 4️⃣ 이미지 메시지 URL 생성
      for (var room in messages.keys) {
        for (var message in messages[room]!) {
          if (message.imagePath != null) {
            makeImageUrlMessage(message);
          }
        }
      }
      calculateUnreadMessages();
      // ✅ 현재 방에 다시 입장 처리
      if (currentRoomId != null) {
        debugPrint("💡 currentRoomId=$currentRoomId → 자동 enterRoom 호출");
        await enterRoom(currentRoomId!);
      }
      // 5️⃣ 디버깅 (최대 20개만 출력)
      // final allMessages = messages.values.expand((list) => list).toList();
      // debugPrint("📦 전체 방 메시지 ${allMessages.length}개 중 최대 20개 출력:");
      // for (int i = 0; i < allMessages.length && i < 20; i++) {
      //   final m = allMessages[i];
      //   logger.d(
      //       "[$i] 📨 messageId: ${m.id}, content: ${m.content}, createdAt: ${m.createdAt}, sender: ${m.userId}");
      // }
      emit(ChatInitial());
      emit(ChatMessageLoaded()); // UI가 이미 이걸 감지하도록 되어 있음
    } catch (e) {
      logger.e("refreshAllMessagesForPush error: $e");
    }
  }

  Future<void> fetchPushOptions() async {
    try {
      final response = await supabase
          .from('room_participants')
          .select('push_option, room_id')
          .eq('user_id', supabase.auth.currentUser!.id);
      logger.d(response);
      _pushOptions = response.fold<Map<String, bool>>(
        {},
        (previousValue, element) => {
          ...previousValue,
          element['room_id'] as String: element['push_option'] as bool
        },
      );
      logger.d("fetchPushOptions: $_pushOptions");
    } catch (e) {
      logger.e('Error fetching push options: $e');
    }
  }

  Future<void> loadChatList() async {
    try {
      final ret = await supabase.from('rooms').select('*, profiles(*)');
      logger.d(ret);
      chatList = ret.map(
        (e) {
          Room room = Room.fromMap(
            e,
            members: (e['profiles'] as List<dynamic>)
                .map((profileRet) => Profile.fromMap(map: profileRet))
                .toList(),
          );
          room.members.sort(
            ((a, b) => a.id == supabase.auth.currentUser!.id
                ? -1
                : b.id == supabase.auth.currentUser!.id
                    ? 1
                    : blockedUsers.contains(a.id)
                        ? 1
                        : blockedUsers.contains(b.id)
                            ? -1
                            : 0),
          );
          return room;
        },
      ).toList();

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
              .limit(1);
          if (response.isEmpty) return room;

          final message = Message.fromMap(
            map: response[0],
            myUserId: supabase.auth.currentUser!.id,
            profile: room.memberMap[response[0]['user_id']]!,
            reactions: [],
            readReceipts: {},
          );

          return room.copyWith(lastMessage: message); // 새로운 Room 객체 반환
        }),
      );

      chatList = updatedChatList;
      chatList.sort((a, b) {
        if (a.lastMessage == null) return 1;
        if (b.lastMessage == null) return -1;
        return b.lastMessage!.createdAt!.compareTo(a.lastMessage!.createdAt!);
      });
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
            logger.d(
                "✅ readReceipts 업데이트: ${room.id} → ${readReceipts[room.id]}");
          }
        }
      });
      await Future.wait(futures);
      logger.d("🔹 fetchLatestReceipt 실행 완료");
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

  Future<void> fetchRoomRanking(Room roomInfo) async {
    try {
      final results = await Future.wait(roomInfo.members.map((member) async {
        logger.d(member);
        final response = await supabase
            .from('weight')
            .select('weight')
            .eq('user_id', member.id)
            .lte('created_at', roomInfo.endDay!.toIso8601String())
            .gte('created_at', roomInfo.startDay!.toIso8601String());
        if (response.isNotEmpty) {
          final weight = (response[response.length - 1]['weight'] as num) -
              (response[0]['weight'] as num);
          return MapEntry(member, weight.toDouble());
          //ranking.add(MapEntry(member, weight.toDouble()));
        } else {
          return MapEntry(member, 0.0);
          //ranking.add(MapEntry(member, 0.0));
        }
      }));
      ranking = [];
      ranking.addAll(results);
      logger.d("fetchRoomRanking: $ranking");
      ranking.sort((a, b) => a.value.compareTo(b.value));

      final sum = ranking.fold<double>(
          0, (previousValue, element) => previousValue + element.value);
      weightAverage = sum / ranking.length;

      emit(ChatListLoaded());
    } catch (e) {
      logger.e('Error fetching room ranking: $e');
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

  void calculateUnreadMessages() {
    unreadMessageCount = 0;

    for (var room in chatList) {
      final roomMessages = messages[room.id];
      if (roomMessages == null || roomMessages.isEmpty) {
        continue; // ✅ 메시지가 없으면 skip
      }

      final unreadMessagesList = roomMessages
          .where((message) =>
              message.createdAt != null &&
              (readReceipts[room.id] == null ||
                  message.createdAt!.isAfter(readReceipts[room.id]!)))
          .toList();

      logger.d("calculateUnreadMessages: ${unreadMessagesList.length}");
      logger.d("readReceipts: ${readReceipts[room.id]}");

      unreadMessages[room.id] = unreadMessagesList.length;
      unreadMessageCount += unreadMessagesList.length;
    }

    emit(UnreadMessagesUpdated(unreadMessageCount, unreadMessages));
  }

  void setMessagesListener() {
    final existingChannels = supabase.getChannels();
    final isAlreadySubscribed = existingChannels.any((c) {
      return c.toString().contains('public:messages');
    });

    if (isAlreadySubscribed) {
      debugPrint("⚠️ 이미 메시지 채널 구독 중, 중복 방지");
      return;
    }

    _messageChannel = supabase
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
              // chatList.sort((a, b) => b.lastMessage!.createdAt!
              //     .compareTo(a.lastMessage!.createdAt!));

              // 6. 정렬 (null safety 적용)
              chatList.sort((a, b) {
                final aTime = a.lastMessage?.createdAt;
                final bTime = b.lastMessage?.createdAt;

                if (aTime == null && bTime == null) return 0;
                if (bTime == null) return -1;
                if (aTime == null) return 1;
                return bTime.compareTo(aTime);
              });

              if (!messages.containsKey(message.roomId)) {
                messages[message.roomId] = [];
              }
              messages[message.roomId] = [
                message,
                ...messages[message.roomId]!
              ];
              if (message.roomId == currentRoomId) {
                sendReadReceipt(message.roomId, message.id!);
              } else {
                await Future.delayed(Duration(milliseconds: 900));
                unreadMessages[message.roomId] =
                    (unreadMessages[message.roomId] ?? 0) + 1;
                unreadMessageCount++;
              }

              emit(ChatMessageLoaded());
            })
        .subscribe();
  }

  void setReactionListener() {
    final existingChannels = supabase.getChannels();
    final isAlreadySubscribed = existingChannels.any((c) {
      return c.toString().contains('public:chat_reactions');
    });

    if (isAlreadySubscribed) {
      debugPrint("⚠️ 이미 리액션 채널 구독 중, 중복 방지");
      return;
    }
    _reactionChannel = supabase
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
    final existingChannels = supabase.getChannels();
    final isAlreadySubscribed = existingChannels.any((c) {
      return c.toString().contains('public:read_receipts');
    });

    if (isAlreadySubscribed) {
      debugPrint("⚠️ 이미 읽음 채널 구독 중, 중복 방지");
      return;
    }
    _readReceiptChannel = supabase
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
              debugPrint("setReadReceiptcallback 실행!");
            })
        .subscribe();
  }

  Future<void> joinRoomByRoomName(String roomName) async {
    try {
      emit(JoinRoomLoading()); // ✅ 로딩 시작

      final trimmedName = roomName.trim();

      final res = await supabase.functions
          .invoke('get-room-id-by-name', body: {'room_name': trimmedName});

      final data = res.data;

      if (res.status == 200 && data != null && data['room_id'] != null) {
        final roomId = data['room_id'] as String;
        logger.d("✅ Edge Function 매칭된 room_id: $roomId");
        await joinRoom(roomId);
      } else {
        logger.e("⛔ 방 이름 매칭 실패: ${data?['error'] ?? 'Unknown'}");
        emit(JoinRoomFailed("방을 찾을 수 없습니다.")); // ❌ 실패 시 상태
      }
    } catch (e, stack) {
      logger.e("❌ joinRoomByRoomName error", error: e, stackTrace: stack);
      emit(JoinRoomFailed("방을 찾을 수 없습니다.")); // ❌ 실패 시 상태
    }
  }

  @override
  Future<void> close() {
    debugPrint("👋 ChatCubit close() called");
    authSubscription.cancel(); // ✅ 스트림 해제

    _messageChannel?.unsubscribe(); // ✅ Supabase 채널 해제
    _reactionChannel?.unsubscribe();
    _readReceiptChannel?.unsubscribe();

    return super.close();
  }

  Future<void> joinRoom(String roomId) async {
    try {
      logger.d(supabase.auth.currentUser!.id);
      await supabase.from('room_participants').insert({
        'room_id': roomId,
        'user_id': supabase.auth.currentUser!.id,
      });
      await loadChatList();
      await Future.wait([
        fetchLatestMessages(),
        loadInitialMessages(),
        fetchLatestReceipt(),
      ]);
      final roomInfo = chatList.firstWhere((room) => room.id == roomId);
      fetchRoomRanking(roomInfo);
      if (roomInfo.startDay != null && roomInfo.endDay != null) {
        try {
          await challengeCubit.enterChallengeByDay(
              roomInfo.startDay!, roomInfo.endDay!);
        } catch (e) {
          logger.e("joinRoom error: $e");
          supabase
              .from('room_participants')
              .delete()
              .eq('room_id', roomId)
              .eq('user_id', supabase.auth.currentUser!.id);
        }
      }
      emit(JoinRoomSuccess()); // ✅ 성공 시 상태
      emit(ChatListLoaded());
    } catch (e) {
      emit(JoinRoomFailed("이미 해당 방에 참여중입니다.")); // ❌ 실패 시 상태
      logger.e("participateRoom error: $e");
    }
  }

  Future<void> enterRoom(String roomId) async {
    debugPrint("🟢 enterRoom 실행됨! roomId: $roomId");
    const maxRetries = 10;
    const delay = Duration(milliseconds: 500);

    bool userFetched = false;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      final user = supabase.auth.currentUser;
      if (user != null) {
        userFetched = true;
        break;
      }
      await Future.delayed(delay);
    }

    if (!userFetched) {
      debugPrint("❗auth.uid()가 끝내 null이었음. roomId=$roomId");
      return; // 여기서 바로 중단해도 좋음!
    }

    debugPrint("현재 채팅방 데이터:");
    for (var room in getChatList) {
      debugPrint("roomId: ${room.id}, roomName: ${room.roomName}");
    }

    // roomMessages 로드될 때까지 대기
    await Future.delayed(delay);

    List<Message>? roomMessages;
    roomMessages = messages[roomId];

    if (roomMessages == null) {
      debugPrint("❗ messages[$roomId]가 끝내 null입니다. 메시지 로드 실패");
      return;
    }

    try {
      currentRoomId = roomId;
      final unreadRoomMessages = roomMessages
          .where((message) =>
              message.createdAt != null &&
              (readReceipts[roomId] == null ||
                  message.createdAt!.isAfter(readReceipts[roomId]!)))
          .toList();
      logger.d("readReceipts: ${readReceipts[roomId]}");
      logger.d("enterRoom: $unreadRoomMessages");
      logger.d("읽지 않은 메시지 총 ${unreadRoomMessages.length}개");
      for (var msg in unreadRoomMessages) {
        logger.d(
            "📩 messageId: ${msg.id}, content: ${msg.content}, createdAt: ${msg.createdAt}, sender: ${msg.userId}");
      }

      // 읽지 않은 메시지를 upsert로 보내기 전에 출력하여 중복 체크
      final readReceiptsMap = unreadRoomMessages
          .map((message) => {
                'room_id': roomId,
                'message_id': message.id,
                'user_id': supabase.auth.currentUser!.id,
              })
          .toList();

      debugPrint("업서트 할 readReceiptsMap: $readReceiptsMap");

      // 중복 체크
      final seen = <String>{};
      final uniqueReadReceiptsMap = <Map<String, dynamic>>[];

      for (var receipt in readReceiptsMap) {
        final key = '${receipt['room_id']}_${receipt['message_id']}';
        if (!seen.contains(key)) {
          seen.add(key);
          uniqueReadReceiptsMap.add(receipt);
        } else {
          debugPrint("중복된 데이터 발견: $receipt");
        }
      }

      // 중복된 데이터 없이 upsert 실행
      if (uniqueReadReceiptsMap.isEmpty) return;

      debugPrint("🔽 upsert 시도 전...");
      try {
        await supabase.from('read_receipts').upsert(uniqueReadReceiptsMap);

        debugPrint("✅ upsert 성공!");
      } catch (e) {
        debugPrint("❌ upsert 실패! 이유: $e");
      }

      readReceipts[roomId] = unreadMessages.isNotEmpty
          ? unreadRoomMessages.first.createdAt
          : DateTime.now();
      unreadMessageCount -= unreadMessages[roomId] ?? 0;
      unreadMessages = unreadMessages.map((key, value) {
        if (key == roomId) {
          return MapEntry(key, 0);
        }
        return MapEntry(key, value);
      });

      emit(ChatMessageLoaded());

      debugPrint("여기 엔터룸 끝났어용");
    } catch (e) {
      logger.e("enterRoom error: $e");
    }
  }

  // Future<void> enterRoom(String roomId) async {
  //   debugPrint("현재 채팅방 데이터:");
  //   for (var room in getChatList) {
  //     debugPrint("roomId: ${room.id}, roomName: ${room.roomName}");
  //   }

  //   try {
  //     currentRoomId = roomId;
  //     final unreadRoomMessages = messages[roomId]!
  //         .where((message) =>
  //             message.createdAt != null &&
  //             (readReceipts[roomId] == null ||
  //                 message.createdAt!.isAfter(readReceipts[roomId]!)))
  //         .toList();
  //     logger.d("readReceipts: ${readReceipts[roomId]}");
  //     logger.d("enterRoom: $unreadRoomMessages");
  //     final readReceiptsMap = unreadRoomMessages
  //         .map((message) => {
  //               'room_id': roomId,
  //               'message_id': message.id,
  //               'user_id': supabase.auth.currentUser!.id,
  //             })
  //         .toList();
  //     if (readReceiptsMap.isEmpty) return;
  //     await supabase.from('read_receipts').upsert(readReceiptsMap);
  //     readReceipts[roomId] = unreadMessages.isNotEmpty
  //         ? unreadRoomMessages.first.createdAt
  //         : DateTime.now();
  //     unreadMessageCount -= unreadMessages[roomId] ?? 0;
  //     unreadMessages = unreadMessages.map((key, value) {
  //       if (key == roomId) {
  //         return MapEntry(key, 0);
  //       }
  //       return MapEntry(key, value);
  //     });
  //     emit(ChatMessageLoaded());
  //   } catch (e) {
  //     logger.e("enterRoom error: $e");
  //   }
  // }

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
        final url = await _getSignedUrlWithRetry(message.imagePath!);

        if (url == null) {
          logger.e("⛔ Signed URL을 생성하지 못했습니다.");
          return;
        }
        messages[message.roomId] = List.from(messages[message.roomId]!.map((m) {
          if (m.id == message.id) {
            m = message.copyWith(imageUrl: url);
          }
          return m;
        }));

        emit(ChatMessageLoaded());
      } catch (e) {
        logger.e("⛔ makeImageUrl error: $e");
      }
    } else {
      logger.w("⚠️ [makeImageUrlMessage] imagePath가 null입니다. 재시도하겠습니다.");
    }
  }

  Future<String?> _getSignedUrlWithRetry(String path, {int retry = 3}) async {
    for (int i = 0; i < retry; i++) {
      try {
        final url = await supabase.storage
            .from('ImageMessages')
            .createSignedUrl(path, 3600 * 12);

        return url;
      } catch (e) {
        logger.w("🔁 createSignedUrl 실패 (시도 ${i + 1}/$retry): $e");

        // 간단한 지연 후 재시도
        await Future.delayed(Duration(milliseconds: 700));
      }
    }
    return null;
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
      messages.forEach((roomId, messageList) {
        messages[roomId] = List.from(messageList.where((message) {
          return message.userId != userId;
        }));
      });
      emit(BlockUserFinished());
      logger.d("blockUser: $userId");
    } catch (e) {
      logger.e("blockUser error: $e");
    }
  }

  void blockMessage(String messageId, String roomId) async {
    try {
      await supabase.from('blocked_messages').upsert({
        'message_id': messageId,
        'user_id': supabase.auth.currentUser!.id,
        'room_id': roomId,
      });
      blockedMessages.add(messageId);
      messages[roomId] = List.from(messages[roomId]!.where((message) {
        return message.id != messageId;
      }));
      emit(ChatMessageLoaded());
      logger.d("blockMessage: $messageId");
    } catch (e) {
      logger.e("blockMessage error: $e");
    }
  }

  Future<void> togglePushOption(String roomId, bool value) async {
    try {
      final res = await supabase
          .from('room_participants')
          .update({
            'push_option': value,
          })
          .eq('room_id', roomId)
          .eq('user_id', supabase.auth.currentUser!.id)
          .select();
      logger.d(res);
      _pushOptions = {
        ..._pushOptions,
        roomId: value,
      };
      emit(ChatPushLoaded());
    } catch (e) {
      logger.e('Error toggling push option: $e');
    }
  }

  void missionComplete({
    required FeedType type,
    required String review,
    double? weight,
    int? exerciseTime,
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
      uploadImage(currentRoomId!, formCubit.selectedImages[contentType]),
      formCubit.feedInfo(
        type: type,
        review: review,
        contentType: contentType,
        calorie: calorie,
        mealContent: mealContent,
        weight: weight,
        exerciseTime: exerciseTime,
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

    Map<FeedType, String> feedHash = {
      FeedType.weight: '#체중',
      FeedType.breakfast: '#아침',
      FeedType.lunch: '#점심',
      FeedType.dinner: '#저녁',
      FeedType.snack: '#간식',
      FeedType.exercise: '#운동',
    };

    try {
      // 트랜잭션 실행
      final feedId = await supabase.rpc('mission_complete', params: {
        'user_id': userId,
        'review': feedData['review'],
        'feed_type': feedData['type'],
        'feed_image_path': feedData['image_path'],
        'calorie': feedData['calorie'],
        'room_id': messageData['room_id'],
        'content': '${feedHash[type]} ${messageData['content']}',
        'message_image_path': messageData['image_path'],
        'message_type': messageData['type'],
        'weight_date': DateTime.now().toIso8601String(),
        'weight': feedData['weight'],
      });
      formCubit.missionComplete(
        type: type,
        review: review,
        contentType: contentType,
        feedId: feedId,
        calorie: calorie,
        mealContent: mealContent,
        weight: weight,
        exerciseTime: exerciseTime,
      );

      logger.d('Certification uploaded successfully!');
    } catch (e) {
      logger.e('Error uploading certification: $e');
    }
    // ✅ 여기 추가!
    challengeCubit.updateMission();
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
  List<String> get getBlockedUsers => blockedUsers;
  Map<String, int> get getUnreadMessages => unreadMessages;
  int get getUnreadMessageCount => unreadMessageCount;
  List<MapEntry<Profile, double>> get getRanking => ranking;
  double get getWeightAverage => weightAverage;
  Map<String, bool> get getPushOptions => _pushOptions;
  bool get isInitialized => _initialized;
  XFile? get selectedImage => _selectedImage;
}
