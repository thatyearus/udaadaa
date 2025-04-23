import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
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
  Map<String, List<Message>> imageMessages = {};

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

  Map<String, List<String>> unreadMessageIdsByRoom = {};

  final AuthCubit authCubit;
  late final StreamSubscription authSubscription;

  RealtimeChannel? _messageChannel;
  RealtimeChannel? _reactionChannel;
  RealtimeChannel? _readReceiptChannel;
  int cnt = 0;

  bool _isLoadingMessages = false;
  final Map<String, bool> _loadingMoreMessages = {};

  final String baseUrl = '$supabaseUrl/storage/v1/object/public/ImageMessages/';

  ChatCubit(this.authCubit, this.formCubit, this.challengeCubit)
      : super(ChatInitial()) {
    debugPrint("🔄 ChatCubit 생성자 호출됨");
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
    try {
      final Dio newDio = Dio(
        BaseOptions(
          baseUrl: supabaseUrl,
          connectTimeout: const Duration(milliseconds: 5000),
          receiveTimeout: const Duration(milliseconds: 9000),
        ),
      );

      final response = await newDio.post(
        initialChatEndPoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNjcGNjbGZxb2Z5dmtzYWpucnBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjUyNzk1ODcsImV4cCI6MjA0MDg1NTU4N30.0wEPsxwBle1E66m4pZ1BW5ZdN4tL88eYL3s2wbnE30k',
          },
        ),
        data: jsonEncode({'userId': supabase.auth.currentUser!.id}),
      );

      logger.d("Response status: ${response.statusCode}");

      // 전체 JSON 데이터 (Map 형태)
      final data = response.data;

      // 최상위 필드 파싱
      blockedUsers = List<String>.from(data['blocked_user_ids'] ?? []);
      blockedMessages = List<String>.from(data['blocked_message_ids'] ?? []);
      _pushOptions = Map<String, bool>.from(data['push_options'] ?? {});
      final chatlistRet =
          List<Map<String, dynamic>>.from(data['chat_list'] ?? []);
      chatList = chatlistRet.map(
        (e) {
          Room room = Room.fromMap(
            e,
            members: (e['profiles'] as List<dynamic>)
                .map((profileRet) => Profile.fromMap(map: profileRet))
                .toList(),
            lastMessage: e['last_message'] != null
                ? Message.fromMap(
                    map: e['last_message'],
                    myUserId: supabase.auth.currentUser!.id,
                    profile: Profile.fromMap(map: e['profiles'][0]),
                    reactions: [],
                    readReceipts: {},
                  )
                : null,
          );

          if (e['last_message'] != null) {
            debugPrint(e['last_message'].toString());
          } else {
            debugPrint("last_message is null");
          }

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

      chatList.sort((a, b) {
        if (a.lastMessage == null) return 1;
        if (b.lastMessage == null) return -1;
        return b.lastMessage!.createdAt!.compareTo(a.lastMessage!.createdAt!);
      });

      readReceipts = Map<String, DateTime?>.from(
        (data['latest_read_receipts'] ?? {}).map((key, value) {
          DateTime? adjustedDateTime = value != null
              ? DateTime.parse(value).add(const Duration(hours: 9))
              : null;
          return MapEntry(key, adjustedDateTime);
        }),
      );

      loadInitialMessages2(jsonData: data['initial_messages']);

      // Process unread message IDs from the data
      try {
        final unreadMessageIdsMap =
            data['unread_message_ids_by_room'] as Map<String, dynamic>?;

        if (unreadMessageIdsMap != null) {
          logger.d("📥 Processing unread message IDs from initial data");
          unreadMessageCount = 0;

          // Reset the unread message counts
          unreadMessageIdsByRoom.clear();
          unreadMessages.clear();

          // Process each room's unread messages
          unreadMessageIdsMap.forEach((roomId, messageIds) {
            try {
              final List<String> ids = (messageIds as List)
                  .map<String>((id) => id.toString())
                  .toList();

              // Store the unread message IDs for this room
              unreadMessageIdsByRoom[roomId] = ids;

              // Update the count for this room
              unreadMessages[roomId] = ids.length;

              // Add to total count
              unreadMessageCount += ids.length;

              logger.d("📥 [Room: $roomId] → ${ids.length}개의 unread 메시지 ID");

              // Log individual message IDs for detailed debugging
              for (var id in ids) {
                logger.d("📥 [Room: $roomId] unread message ID: $id");
              }
            } catch (e) {
              logger
                  .e("⛔ Error processing unread messages for room $roomId: $e");
            }
          });

          logger.d(
              "📥 Total unread messages across all rooms: $unreadMessageCount");
        } else {
          logger.w("⚠️ No unread message IDs found in initial data");
        }
      } catch (e) {
        logger.e("⛔ Error processing unread message IDs: $e");
      }

      try {
        final imageMessagesMap =
            data['image_messages_by_room'] as Map<String, dynamic>?;
        if (imageMessagesMap != null) {
          logger.d("🖼️ Processing image messages from initial data");
          imageMessages.clear();

          // const baseUrl =
          //     'https://ccpcclfqofyvksajnrpg.supabase.co/storage/v1/object/public/ImageMessages/';

          // Process each room's image messages
          imageMessagesMap.forEach((roomId, messages) {
            try {
              final List<dynamic> messagesList = messages as List<dynamic>;

              // Convert raw data to Message objects with proper image URLs
              imageMessages[roomId] = messagesList
                  .map((row) => Message.fromMap(
                        map: row,
                        myUserId: supabase.auth.currentUser!.id,
                        profile: Profile.fromMap(map: row['profiles']),
                        reactions: (row['chat_reactions'] as List<dynamic>)
                            .map((reactionRet) =>
                                Reaction.fromMap(map: reactionRet))
                            .toList(),
                        readReceipts: (row['read_receipts'] as List<dynamic>)
                            .map(
                                (receiptRet) => receiptRet['user_id'] as String)
                            .toSet(),
                      ))
                  .map((message) => message.copyWith(
                      imageUrl: message.imagePath != null
                          ? '$baseUrl${message.imagePath}'
                          : null))
                  .toList();

              logger.d(
                  "🖼️ [Room: $roomId] → ${imageMessages[roomId]?.length ?? 0}개의 이미지 메시지 로드됨");
            } catch (e) {
              logger
                  .e("⛔ Error processing image messages for room $roomId: $e");
              // Initialize with empty list on error
              imageMessages[roomId] = [];
            }
          });

          logger.d(
              "🖼️ Finished processing image messages for ${imageMessages.length} rooms");
        } else {
          logger.w("⚠️ No image messages found in initial data");
        }
      } catch (e) {
        logger.e("⛔ Error processing image messages: $e");
        // Initialize empty map on error
        imageMessages.clear();
      }

      debugPrint(
          "📜 Latest Read Receipts: \n${readReceipts.entries.map((entry) => 'Room ID: ${entry.key}, Last Read: ${entry.value}').join('\n')}");

      // 디버깅 출력
      debugPrint("🔒 Blocked User IDs: $blockedUsers");
      debugPrint("🧱 Blocked Message IDs: $blockedMessages");
      debugPrint("📬 Push Options: $_pushOptions");
      debugPrint("💬 Chat List Count: ${chatList.length}");
      debugPrint("💬 Image Messages Count: ${imageMessages.length}");
    } catch (e) {
      logger.e("Error posting initial chat data: $e");
    }

    try {
      await Future.wait([
        // fetchBlockedUsers(),
        // fetchBlockedMessages(),
      ]);

      // await fetchPushOptions();
      // await loadChatList();
      // await fetchLatestMessages();
      // await fetchLatestReceipt();

      await Future.wait([
        // loadInitialMessages1(),
        // fetchUnreadMessageIdsAfterLatestReceipt(),
      ]);

      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage message) async {
        wasPushHandled = true;

        if (message.data['roomId'] != null) {
          emit(ChatPushStarted());
        }

        await Future.delayed(Duration(milliseconds: 300));
        await refreshAllMessagesForPush();

        if (message.data['roomId'] != null) {
          final roomId = message.data['roomId'];
          final roomInfo = chatList.firstWhere((room) => room.id == roomId);

          if (message.data['roomId'] != null) {
            emit(ChatPushOpenedFromBackground(
              roomId,
              "알림을 클릭하여 들어왔습니다.",
              roomInfo,
            ));
          }
        }
      });

      setChatEventsListener();
      _initialized = true;
      debugPrint("✅ 초기화 완료!");

      // loadImageMessages();
    } catch (e) {
      logger.e("초기화 실패: $e");
    }
  }

  // Future<void> _initialize() async {
  //   try {
  //     await Future.wait([
  //       fetchBlockedUsers(),
  //       fetchBlockedMessages(),
  //     ]);

  //     await fetchPushOptions();
  //     await loadChatList();
  //     await fetchLatestMessages();
  //     await fetchLatestReceipt();

  //     await Future.wait([
  //       loadInitialMessages1(),
  //       fetchUnreadMessageIdsAfterLatestReceipt(),
  //     ]);

  //     FirebaseMessaging.onMessageOpenedApp
  //         .listen((RemoteMessage message) async {
  //       wasPushHandled = true;

  //       if (message.data['roomId'] != null) {
  //         emit(ChatPushStarted());
  //       }

  //       await Future.delayed(Duration(milliseconds: 500));

  //       await refreshAllMessagesForPush();

  //       if (message.data['roomId'] != null) {
  //         final roomId = message.data['roomId'];
  //         final roomInfo = chatList.firstWhere((room) => room.id == roomId);

  //         if (message.data['roomId'] != null) {
  //           emit(ChatPushOpenedFromBackground(
  //             roomId,
  //             "알림을 클릭하여 들어왔습니다.",
  //             roomInfo,
  //           ));
  //         }
  //       }
  //     });

  //     setChatEventsListener();
  //     _initialized = true;
  //     debugPrint("✅ 초기화 완료!");

  //     loadImageMessages();
  //   } catch (e) {
  //     logger.e("초기화 실패: $e");
  //   }
  // }

  Future<void> refreshAllMessagesForPush() async {
    try {
      // 1️⃣ 기존 모든 메시지 초기화
      messages.clear();

      await loadChatList();
      await fetchLatestMessages();
      await fetchLatestReceipt();

      await Future.wait([
        loadInitialMessages1(),
        fetchUnreadMessageIdsAfterLatestReceipt(),
      ]);

      // ✅ 현재 방에 다시 입장 처리
      if (currentRoomId != null) {
        debugPrint("💡 currentRoomId=$currentRoomId → 자동 enterRoom 호출");
        await enterRoom1(currentRoomId!);
      }

      emit(ChatInitial());
      emit(ChatMessageLoaded());
    } catch (e) {
      logger.e("refreshAllMessagesForPush error: $e");
    }
  }

  Future<void> processImageMessages(List<Message> messages) async {
    const int batchSize = 30;

    for (var i = 0; i < messages.length; i += batchSize) {
      final batch = messages.skip(i).take(batchSize).toList();

      await Future.wait(
        batch.map((message) async {
          if (message.imagePath != null) {
            await makeImageUrlMessage(message);
          }
        }),
      );

      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<void> makeImageUrlMessage(Message message, {emitLoaded = true}) async {
    if (message.imagePath != null) {
      // final baseUrl =
      //     'https://ccpcclfqofyvksajnrpg.supabase.co/storage/v1/object/public/ImageMessages/';
      final fullUrl = '$baseUrl${message.imagePath}';

      messages[message.roomId] = List.from(messages[message.roomId]!.map((m) {
        if (m.id == message.id) {
          m = message.copyWith(imageUrl: fullUrl);
        }
        return m;
      }));

      if (emitLoaded) {
        emit(ChatMessageLoaded());
      }
    } else {
      logger.w("⚠️ [makeImageUrlMessage] imagePath가 null입니다. 재시도하겠습니다.");
    }
    cnt++;
  }

  // private 방식
  // Future<void> makeImageUrlMessage(Message message, {emitLoaded = true}) async {
  //   if (message.imagePath != null) {
  //     try {
  //       final url = await _getSignedUrlWithRetry(message.imagePath!);

  //       if (url == null) {
  //         logger.e("⛔ Signed URL을 생성하지 못했습니다.");
  //         return;
  //       }
  //       messages[message.roomId] = List.from(messages[message.roomId]!.map((m) {
  //         if (m.id == message.id) {
  //           m = message.copyWith(imageUrl: url);
  //         }
  //         return m;
  //       }));

  //       if (emitLoaded) {
  //         emit(ChatMessageLoaded());
  //       }
  //     } catch (e) {
  //       logger.e("⛔ makeImageUrl error: $e");
  //     }
  //   } else {
  //     logger.w("⚠️ [makeImageUrlMessage] imagePath가 null입니다. 재시도하겠습니다.");
  //   }
  //   cnt++;
  // }

  // Future<String?> _getSignedUrlWithRetry(String path, {int retry = 4}) async {
  //   for (int i = 0; i < retry; i++) {
  //     try {
  //       final url = await supabase.storage
  //           .from('ImageMessages')
  //           .createSignedUrl(path, 3600 * 3)
  //           .timeout(const Duration(milliseconds: 700));

  //       return url;
  //     } catch (e) {
  //       logger.w("🔁 createSignedUrl 실패 (시도 ${i + 1}/$retry): $e");
  //       await Future.delayed(Duration(milliseconds: 300));
  //     }
  //   }
  //   return null;
  // }

  Future<void> fetchUnreadMessageIdsAfterLatestReceipt(
      {bool emitLoaded = true}) async {
    unreadMessageCount = 0;
    final userId = supabase.auth.currentUser!.id;

    try {
      for (final room in chatList) {
        final latestReceipt = readReceipts[room.id];
        debugPrint("📬 [${room.roomName}] latestReceipt (KST): $latestReceipt");

        var query = supabase
            .from('messages')
            .select('id, created_at')
            .eq('room_id', room.id)
            .neq('user_id', userId);

        if (latestReceipt != null) {
          // KST에서 UTC로 변환 (KST는 UTC+9)
          // 9시간을 빼서 UTC로 변환
          final adjusted = latestReceipt.subtract(const Duration(hours: 9));
          debugPrint("🕐 [${room.roomName}] KST: $latestReceipt");
          debugPrint("🕐 [${room.roomName}] UTC: $adjusted");
          debugPrint(
              "🕐 [${room.roomName}] ISO8601: ${adjusted.toIso8601String()}");

          query = query.gt('created_at', adjusted.toIso8601String());
        }

        final response = await query;

        final ids = response.map<String>((row) => row['id'] as String).toList();
        unreadMessageIdsByRoom[room.id] = ids;

        unreadMessages[room.id] = ids.length;
        unreadMessageCount += ids.length;

        // 각 unread 메시지 ID도 출력
        for (var id in ids) {
          logger.d("📥 [${room.roomName}] unread message ID: $id");
        }

        logger.d("📥 [${room.roomName}] → ${ids.length}개의 unread 메시지 ID");
      }
    } catch (e) {
      logger.e("fetchUnreadMessageIdsAfterLatestReceipt error: $e");
    }
    if (emitLoaded) {
      emit(ChatMessageLoaded());
    }
  }

  Future<void> fetchPushOptions() async {
    try {
      final response = await supabase
          .from('room_participants')
          .select('push_option, room_id')
          .eq('user_id', supabase.auth.currentUser!.id);
      // logger.d(response);
      _pushOptions = response.fold<Map<String, bool>>(
        {},
        (previousValue, element) => {
          ...previousValue,
          element['room_id'] as String: element['push_option'] as bool
        },
      );
      // logger.d("fetchPushOptions: $_pushOptions");
    } catch (e) {
      logger.e('Error fetching push options: $e');
    }
  }

  Future<void> loadChatList({bool emitLoaded = true}) async {
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
      if (emitLoaded) {
        emit(ChatListLoaded());
      }
    } catch (e) {
      logger.e("loadChatList error: $e");
    }
  }

  Future<void> fetchLatestMessages({bool emitLoaded = true}) async {
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
      if (emitLoaded) {
        emit(ChatListLoaded());
      }
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
          final createdAt = DateTime.parse(response[0]['created_at']);

          if (readReceipts[room.id] == null ||
              readReceipts[room.id]!.isBefore(createdAt)) {
            readReceipts[room.id] = createdAt.add(const Duration(hours: 9));
            logger.d(
                "✅ readReceipts 업데이트: ${room.id} → ${readReceipts[room.id]}");
          }
        }
      });
      await Future.wait(futures);
      logger.d("🔹 fetchLatestReceipt 실행 완료");
    } catch (e) {
      logger.e('Error fetching latest read receipts: $e');
    }
    debugPrint(
        "📜 Latest Read Receipts: \n${readReceipts.entries.map((entry) => 'Room ID: ${entry.key}, Last Read: ${entry.value}').join('\n')}");
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

  Future<void> fetchRoomRanking(Room roomInfo, {emitLoaded = true}) async {
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

      if (emitLoaded) {
        emit(ChatListLoaded());
      }
    } catch (e) {
      logger.e('Error fetching room ranking: $e');
    }
  }

  Future<void> loadMoreMessages() async {
    if (currentRoomId == null || _loadingMoreMessages[currentRoomId] == true) {
      return;
    }

    final existingMessages = messages[currentRoomId!];
    if (existingMessages == null || existingMessages.isEmpty) return;

    try {
      _loadingMoreMessages[currentRoomId!] = true;

      final oldestMessage = existingMessages.last;
      if (oldestMessage.createdAt == null) {
        logger.w("🚫 oldestMessage.createdAt이 null입니다. 메시지를 불러올 수 없습니다.");
        return;
      }

      final oldestTime =
          oldestMessage.createdAt!.subtract(const Duration(hours: 9));

      final ret = await supabase
          .from('messages')
          .select(
              "*, profiles!messages_user_id_fkey(*), chat_reactions(*), read_receipts(user_id)")
          .eq('room_id', currentRoomId!)
          .lt('created_at', oldestTime.toIso8601String())
          .not('user_id', 'in', blockedUsers)
          .not('id', 'in', blockedMessages)
          .order('created_at', ascending: false)
          .limit(20);

      final newMessages = ret
          .map((row) => Message.fromMap(
                map: row,
                myUserId: supabase.auth.currentUser!.id,
                profile: Profile.fromMap(map: row['profiles']),
                reactions: (row['chat_reactions'] as List<dynamic>)
                    .map((reactionRet) => Reaction.fromMap(map: reactionRet))
                    .toList(),
                readReceipts: (row['read_receipts'] as List<dynamic>)
                    .map((receiptRet) => receiptRet['user_id'] as String)
                    .toSet(),
              ))
          .toList();

      messages[currentRoomId!]!.addAll(newMessages);

      for (var message in newMessages) {
        if (message.imagePath != null) {
          await makeImageUrlMessage(message);
        }
      }

      // ✅ 로드 후 전체 메시지 로그
      final updatedMessages = messages[currentRoomId]!;
      debugPrint("🆕 업데이트된 메시지 (${updatedMessages.length}개):");
      for (int i = 0; i < updatedMessages.length; i++) {
        debugPrint("  [$i] ${updatedMessages[i].content}");
      }

      emit(ChatMessageLoaded());
    } catch (e) {
      logger.e("loadMoreMessages error: $e");
    } finally {
      _loadingMoreMessages[currentRoomId!] = false;
    }
  }

  Future<void> loadInitialMessages2(
      {bool emitLoaded = true, Map<String, dynamic>? jsonData}) async {
    if (chatList.isEmpty) {
      logger.w("⚠️ chatList가 비어있습니다");
      return;
    }

    if (jsonData == null) {
      logger.w("⚠️ jsonData가 null입니다");
      return;
    }

    try {
      // jsonData의 각 키(roomId)에 대해 처리
      for (final roomId in jsonData.keys) {
        logger.d("🔄 처리 중인 roomId: $roomId");

        try {
          final messagesData = jsonData[roomId] as List<dynamic>;

          // 기존 메시지 초기화하고 새로 저장하기!
          messages[roomId] = messagesData
              .map((row) => Message.fromMap(
                    map: row,
                    myUserId: supabase.auth.currentUser!.id,
                    profile: Profile.fromMap(map: row['profiles']),
                    reactions: (row['chat_reactions'] as List<dynamic>)
                        .map(
                            (reactionRet) => Reaction.fromMap(map: reactionRet))
                        .toList(),
                    readReceipts: (row['read_receipts'] as List<dynamic>)
                        .map((receiptRet) => receiptRet['user_id'] as String)
                        .toSet(),
                  ))
              .toList();

          // 이미지 메시지 처리
          for (var message in messages[roomId]!) {
            if (message.imagePath != null) {
              if (emitLoaded) {
                await makeImageUrlMessage(message);
              } else {
                await makeImageUrlMessage(message, emitLoaded: false);
              }
            }
          }

          logger.d(
              "✅ roomId: $roomId에 대한 메시지 ${messages[roomId]?.length ?? 0}개 로드 완료");
        } catch (innerError) {
          logger.e("❌ roomId: $roomId 처리 중 오류 발생: $innerError");
        }
      }

      if (emitLoaded) {
        emit(ChatMessageLoaded());
      }
    } catch (e) {
      logger.e("loadInitialMessages2 error: $e");
    } finally {
      _isLoadingMessages = false;
    }
  }

  Future<void> loadInitialMessages1({bool emitLoaded = true}) async {
    if (chatList.isEmpty) {
      logger.w("⚠️ chatList가 비어있습니다");
      return;
    }
    // if (_isLoadingMessages) {
    //   logger.w("⚠️ 이미 로딩 중입니다!");
    //   return;
    // }

    try {
      for (final room in chatList) {
        final roomId = room.id;
        final ret = await supabase
            .from('messages')
            .select(
                "*, profiles!messages_user_id_fkey(*), chat_reactions(*), read_receipts(user_id)")
            .eq('room_id', roomId)
            .not('user_id', 'in', blockedUsers)
            .not('id', 'in', blockedMessages)
            .order('created_at', ascending: false)
            .limit(20);

        // ✅ 기존 메시지 초기화하고 새로 저장하기!
        messages[roomId] = ret
            .map((row) => Message.fromMap(
                  map: row,
                  myUserId: supabase.auth.currentUser!.id,
                  profile: Profile.fromMap(map: row['profiles']),
                  reactions: (row['chat_reactions'] as List<dynamic>)
                      .map((reactionRet) => Reaction.fromMap(map: reactionRet))
                      .toList(),
                  readReceipts: (row['read_receipts'] as List<dynamic>)
                      .map((receiptRet) => receiptRet['user_id'] as String)
                      .toSet(),
                ))
            .toList();

        for (var message in messages[roomId]!) {
          if (message.imagePath != null) {
            if (emitLoaded) {
              await makeImageUrlMessage(message);
            } else {
              await makeImageUrlMessage(message, emitLoaded: false);
            }
          }
        }
      }
      if (emitLoaded) {
        emit(ChatMessageLoaded());
      }
    } catch (e) {
      logger.e("loadInitialMessages1 error : $e");
    } finally {
      _isLoadingMessages = false;
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

      // for (var room in messages.keys) {
      //   final imageMessages =
      //       messages[room]!.where((msg) => msg.imagePath != null).toList();
      //   await processImageMessages(imageMessages);
      // }

      for (var room in messages.keys) {
        for (var message in messages[room]!) {
          if (message.imagePath != null) makeImageUrlMessage(message);
        }
        // if (message.type == 'imageMessage') makeImageUrlMessage(message);
      }
      emit(ChatMessageLoaded());
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

  // void setMessagesListener() {
  //   final existingChannels = supabase.getChannels();
  //   final isAlreadySubscribed = existingChannels.any((c) {
  //     return c.toString().contains('public:messages');
  //   });

  //   if (isAlreadySubscribed) {
  //     debugPrint("⚠️ 이미 메시지 채널 구독 중, 중복 방지");
  //     return;
  //   }

  //   _messageChannel = supabase
  //       .channel('public:messages')
  //       .onPostgresChanges(
  //           event: PostgresChangeEvent.insert,
  //           schema: 'public',
  //           table: 'messages',
  //           callback: (payload) async {
  //             if (blockedUsers.contains(payload.newRecord['user_id'])) return;
  //             final profileRet = await supabase
  //                 .from('profiles')
  //                 .select()
  //                 .eq('id', payload.newRecord['user_id'])
  //                 .single();
  //             final message = Message.fromMap(
  //               map: payload.newRecord,
  //               myUserId: supabase.auth.currentUser!.id,
  //               profile: Profile.fromMap(map: profileRet),
  //               reactions: [],
  //               readReceipts: {},
  //             );
  //             if (message.imagePath != null) await makeImageUrlMessage(message);
  //             logger.d("setMessagesListener: $message");
  //             // messages = [message, ...messages];
  //             final updatedChatList = List<Room>.from(chatList);
  //             final roomIndex = updatedChatList
  //                 .indexWhere((room) => room.id == message.roomId);

  //             if (roomIndex != -1) {
  //               updatedChatList[roomIndex] =
  //                   updatedChatList[roomIndex].copyWith(
  //                 lastMessage: message,
  //               );
  //             }
  //             chatList = updatedChatList;
  //             // chatList.sort((a, b) => b.lastMessage!.createdAt!
  //             //     .compareTo(a.lastMessage!.createdAt!));

  //             // 6. 정렬 (null safety 적용)
  //             chatList.sort((a, b) {
  //               final aTime = a.lastMessage?.createdAt;
  //               final bTime = b.lastMessage?.createdAt;

  //               if (aTime == null && bTime == null) return 0;
  //               if (bTime == null) return -1;
  //               if (aTime == null) return 1;
  //               return bTime.compareTo(aTime);
  //             });

  //             if (!messages.containsKey(message.roomId)) {
  //               messages[message.roomId] = [];
  //             }
  //             messages[message.roomId] = [
  //               message,
  //               ...messages[message.roomId]!
  //             ];
  //             if (message.roomId == currentRoomId) {
  //               sendReadReceipt(message.roomId, message.id!);
  //             } else {
  //               unreadMessages[message.roomId] =
  //                   (unreadMessages[message.roomId] ?? 0) + 1;
  //               unreadMessageCount++;
  //             }

  //             emit(ChatMessageLoaded());
  //           })
  //       .subscribe();
  // }

  void setChatEventsListener() {
    final existingChannels = supabase.getChannels();
    if (existingChannels
        .any((c) => c.toString().contains('public:chat_events'))) {
      debugPrint("⚠️ 이미 chat_events 채널 구독 중");
      return;
    }

    _messageChannel = supabase.channel('public:chat_events');

    _messageChannel!
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'messages',
        callback: (payload) async {
          final newMsg = payload.newRecord;
          if (blockedUsers.contains(newMsg['user_id'])) return;

          final profileRet = await supabase
              .from('profiles')
              .select()
              .eq('id', newMsg['user_id'])
              .single();

          final message = Message.fromMap(
            map: newMsg,
            myUserId: supabase.auth.currentUser!.id,
            profile: Profile.fromMap(map: profileRet),
            reactions: [],
            readReceipts: {},
          );

          //메시지 추가
          if (!messages.containsKey(message.roomId)) {
            messages[message.roomId] = [];
          }
          messages[message.roomId] = [message, ...messages[message.roomId]!];

          if (message.imagePath != null) {
            await makeImageUrlMessage(message);
          }

          //이미지 메시지 추가
          if (message.imagePath != null) {
            if (!imageMessages.containsKey(message.roomId)) {
              imageMessages[message.roomId] = [];
            }
            imageMessages[message.roomId] = [
              message,
              ...imageMessages[message.roomId]!
            ];
            await makeImageUrlImageMessage(message);
          }

          final index =
              chatList.indexWhere((room) => room.id == message.roomId);
          if (index != -1) {
            chatList[index] = chatList[index].copyWith(lastMessage: message);
          }

          chatList.sort((a, b) {
            final aTime = a.lastMessage?.createdAt;
            final bTime = b.lastMessage?.createdAt;
            if (aTime == null && bTime == null) return 0;
            if (bTime == null) return -1;
            if (aTime == null) return 1;
            return bTime.compareTo(aTime);
          });

          if (message.roomId == currentRoomId) {
            sendReadReceipt(message.roomId, message.id!);
          } else {
            unreadMessageIdsByRoom[message.roomId] ??=
                []; // 리스트가 없다면 빈 리스트로 초기화
            unreadMessageIdsByRoom[message.roomId]!.add(message.id!);
            unreadMessages[message.roomId] =
                (unreadMessages[message.roomId] ?? 0) + 1;
            unreadMessageCount++;
          }

          emit(ChatMessageLoaded());
        },
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'chat_reactions',
        callback: (payload) {
          final reaction = Reaction.fromMap(map: payload.newRecord);
          messages[reaction.roomId] =
              List.from(messages[reaction.roomId]!.map((message) {
            if (message.id == reaction.messageId) {
              message =
                  message.copyWith(reactions: [reaction, ...message.reactions]);
            }
            return message;
          }));
          emit(ChatMessageLoaded());
        },
      )
      ..onPostgresChanges(
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
        },
      )
      ..subscribe();
  }

  // void setReactionListener() {
  //   final existingChannels = supabase.getChannels();
  //   final isAlreadySubscribed = existingChannels.any((c) {
  //     return c.toString().contains('public:chat_reactions');
  //   });

  //   if (isAlreadySubscribed) {
  //     debugPrint("⚠️ 이미 리액션 채널 구독 중, 중복 방지");
  //     return;
  //   }
  //   _reactionChannel = supabase
  //       .channel('public:chat_reactions')
  //       .onPostgresChanges(
  //           event: PostgresChangeEvent.insert,
  //           schema: 'public',
  //           table: 'chat_reactions',
  //           callback: (payload) {
  //             final reaction = Reaction.fromMap(
  //               map: payload.newRecord,
  //             );
  //             /*
  //             messages = messages.map((message) {
  //               if (message.id == reaction.messageId) {
  //                 message.reactions = [reaction, ...message.reactions];
  //               }
  //               return message;
  //             }).toList();*/
  //             messages[reaction.roomId] =
  //                 List.from(messages[reaction.roomId]!.map((message) {
  //               if (message.id == reaction.messageId) {
  //                 message = message
  //                     .copyWith(reactions: [reaction, ...message.reactions]);
  //               }
  //               return message;
  //             }));
  //             logger.d("setReactionListener: $reaction");
  //             emit(ChatMessageLoaded());
  //           })
  //       .subscribe();
  // }

  // void setReadReceiptListener() {
  //   final existingChannels = supabase.getChannels();
  //   final isAlreadySubscribed = existingChannels.any((c) {
  //     return c.toString().contains('public:read_receipts');
  //   });

  //   if (isAlreadySubscribed) {
  //     debugPrint("⚠️ 이미 읽음 채널 구독 중, 중복 방지");
  //     return;
  //   }
  //   _readReceiptChannel = supabase
  //       .channel('public:read_receipts')
  //       .onPostgresChanges(
  //           event: PostgresChangeEvent.insert,
  //           schema: 'public',
  //           table: 'read_receipts',
  //           callback: (payload) {
  //             final roomId = payload.newRecord['room_id'];
  //             messages[roomId] = List.from(messages[roomId]!.map((message) {
  //               if (message.id == payload.newRecord['message_id']) {
  //                 message = message.copyWith(readReceipts: {
  //                   ...message.readReceipts,
  //                   payload.newRecord['user_id'],
  //                 });
  //               }
  //               return message;
  //             }));
  //             emit(ChatMessageLoaded());
  //             debugPrint("setReadReceiptcallback 실행!");
  //           })
  //       .subscribe();
  // }

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
        await fetchUnreadMessageIdsAfterLatestReceipt(emitLoaded: true);
      } else {
        logger.e("⛔ 방 이름 매칭 실패: ${data?['error'] ?? 'Unknown'}");
        emit(JoinRoomFailed("방을 찾을 수 없습니다.")); // ❌ 실패 시 상태
        return;
      }
    } catch (e, stack) {
      logger.e("❌ joinRoomByRoomName error", error: e, stackTrace: stack);
      emit(JoinRoomFailed("방을 찾을 수 없습니다.")); // ❌ 실패 시 상태
      return;
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
      await loadChatList(emitLoaded: false);
      await Future.wait([
        fetchLatestMessages(emitLoaded: false),
        fetchLatestReceipt(),
      ]);
      await Future.wait([
        loadInitialMessages1(emitLoaded: false),
        loadImageMessages(),
      ]);
      final roomInfo = chatList.firstWhere((room) => room.id == roomId);
      await fetchRoomRanking(roomInfo, emitLoaded: false);
      if (roomInfo.startDay != null && roomInfo.endDay != null) {
        try {
          debugPrint("5");
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
    } catch (e) {
      emit(JoinRoomFailed("이미 해당 방에 참여중입니다.")); // ❌ 실패 시 상태
      logger.e("participateRoom error: $e");
      return;
    }
    emit(JoinRoomSuccess()); // ✅ 성공 시 상태
    emit(ChatMessageLoaded());
  }

  Future<void> enterRoom1(String roomId) async {
    debugPrint("🟢 enterRoom1 실행됨! roomId: $roomId");

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

    try {
      currentRoomId = roomId;

      // 1. 읽지 않은 메시지 ID 목록 가져오기
      final unreadMessageIds = unreadMessageIdsByRoom[roomId] ?? [];
      debugPrint("📥 읽지 않은 메시지 ID들: $unreadMessageIds");

      if (unreadMessageIds.isEmpty) {
        debugPrint("읽지 않은 메시지가 없습니다. 읽음 상태 업데이트를 건너뜁니다.");
        emit(ChatMessageLoaded());
        return;
      }

      // 2. 읽음 영수증 생성
      final readReceiptsMap = unreadMessageIds.map((messageId) {
        return {
          'room_id': roomId,
          'message_id': messageId,
          'user_id': supabase.auth.currentUser!.id,
        };
      }).toList();

      debugPrint("업서트 할 readReceiptsMap: $readReceiptsMap");

      // 3. 중복 제거
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

      // 4. 읽음 상태 업데이트 (최대 3번 재시도)
      bool updateSuccess = false;
      int retryCount = 0;
      const maxUpdateRetries = 3;

      while (!updateSuccess && retryCount < maxUpdateRetries) {
        try {
          await supabase.from('read_receipts').upsert(uniqueReadReceiptsMap);
          debugPrint("✅ 읽음 상태 업데이트 성공!");
          updateSuccess = true;
        } catch (e) {
          retryCount++;
          debugPrint(
              "❌ 읽음 상태 업데이트 실패! (시도 $retryCount/$maxUpdateRetries) 이유: $e");
          if (retryCount < maxUpdateRetries) {
            await Future.delayed(
                Duration(milliseconds: 500 * retryCount)); // 지수 백오프
          }
        }
      }

      if (!updateSuccess) {
        debugPrint("⚠️ 읽음 상태 업데이트 최대 시도 횟수 초과. 계속 진행합니다.");
      }

      // 5. 로컬 상태 업데이트
      final previousUnreadCount = unreadMessages[roomId] ?? 0;

      // 5.1 메시지 목록에서 읽음 상태 업데이트
      if (messages.containsKey(roomId)) {
        messages[roomId] = List.from(messages[roomId]!.map((message) {
          if (unreadMessageIds.contains(message.id)) {
            return message.copyWith(readReceipts: {
              ...message.readReceipts,
              supabase.auth.currentUser!.id
            });
          }
          return message;
        }));
      }

      // 5.2 읽지 않은 메시지 카운트 감소
      unreadMessageCount -= previousUnreadCount;

      // 5.3 읽지 않은 메시지 상태 초기화
      unreadMessages[roomId] = 0;
      unreadMessageIdsByRoom[roomId] = [];

      // 5.4 읽음 영수증 타임스탬프 업데이트
      readReceipts[roomId] = DateTime.now();
      debugPrint("현재 읽음 시간${readReceipts[roomId]}");

      // 6. UI 갱신을 위한 상태 이벤트 발생
      emit(ChatMessageLoaded());
      emit(UnreadMessagesUpdated(
          unreadMessageCount, unreadMessages)); // 필요한 인자 전달

      debugPrint("✅ 읽음 처리 완료: 이전 미읽수 $previousUnreadCount개 감소됨");
      debugPrint("여기 enterRoom1 끝났어용");
    } catch (e) {
      logger.e("enterRoom1 error: $e");
      debugPrint("❌ enterRoom1 오류 발생: $e");
    }
  }

  // Future<void> enterRoom(String roomId) async {
  //   debugPrint("🟢 enterRoom 실행됨! roomId: $roomId");
  //   const maxRetries = 10;
  //   const delay = Duration(milliseconds: 500);

  //   bool userFetched = false;

  //   for (int attempt = 0; attempt < maxRetries; attempt++) {
  //     final user = supabase.auth.currentUser;
  //     if (user != null) {
  //       userFetched = true;
  //       break;
  //     }
  //     await Future.delayed(delay);
  //   }

  //   if (!userFetched) {
  //     debugPrint("❗auth.uid()가 끝내 null이었음. roomId=$roomId");
  //     return;
  //   }

  //   debugPrint("현재 채팅방 데이터:");
  //   for (var room in getChatList) {
  //     debugPrint("roomId: ${room.id}, roomName: ${room.roomName}");
  //   }

  //   // roomMessages 로드될 때까지 대기
  //   await Future.delayed(delay);

  //   List<Message>? roomMessages;
  //   roomMessages = messages[roomId];

  //   if (roomMessages == null) {
  //     debugPrint("❗ messages[$roomId]가 끝내 null입니다. 메시지 로드 실패");
  //     return;
  //   }

  //   try {
  //     currentRoomId = roomId;

  //     // Get all unread messages for this room
  //     final unreadRoomMessages = roomMessages
  //         .where((message) =>
  //             message.createdAt != null &&
  //             (readReceipts[roomId] == null ||
  //                 message.createdAt!.isAfter(readReceipts[roomId]!)))
  //         .toList();

  //     logger.d("readReceipts: ${readReceipts[roomId]}");
  //     logger.d("enterRoom: $unreadRoomMessages");
  //     logger.d("읽지 않은 메시지 총 ${unreadRoomMessages.length}개");

  //     for (var msg in unreadRoomMessages) {
  //       logger.d(
  //           "📩 messageId: ${msg.id}, content: ${msg.content}, createdAt: ${msg.createdAt}, sender: ${msg.userId}");
  //     }

  //     // Create read receipts for all unread messages
  //     final readReceiptsMap = unreadRoomMessages
  //         .map((message) => {
  //               'room_id': roomId,
  //               'message_id': message.id,
  //               'user_id': supabase.auth.currentUser!.id,
  //               'created_at': DateTime.now().toIso8601String(), // Add timestamp
  //             })
  //         .toList();

  //     debugPrint("업서트 할 readReceiptsMap: $readReceiptsMap");

  //     // Remove duplicates
  //     final seen = <String>{};
  //     final uniqueReadReceiptsMap = <Map<String, dynamic>>[];

  //     for (var receipt in readReceiptsMap) {
  //       final key = '${receipt['room_id']}_${receipt['message_id']}';
  //       if (!seen.contains(key)) {
  //         seen.add(key);
  //         uniqueReadReceiptsMap.add(receipt);
  //       } else {
  //         debugPrint("중복된 데이터 발견: $receipt");
  //       }
  //     }

  //     // Send read receipts to server
  //     if (uniqueReadReceiptsMap.isNotEmpty) {
  //       debugPrint("🔽 upsert 시도 전...");
  //       try {
  //         await supabase.from('read_receipts').upsert(uniqueReadReceiptsMap);
  //         debugPrint("✅ upsert 성공!");

  //         // Update local state after successful server update
  //         readReceipts[roomId] = unreadMessages.isNotEmpty
  //             ? unreadRoomMessages.first.createdAt
  //             : DateTime.now();

  //         // Update unread counts
  //         final previousUnreadCount = unreadMessages[roomId] ?? 0;
  //         unreadMessageCount -= previousUnreadCount;
  //         unreadMessages = unreadMessages.map((key, value) {
  //           if (key == roomId) {
  //             return MapEntry(key, 0);
  //           }
  //           return MapEntry(key, value);
  //         });

  //         // Emit state update
  //         emit(ChatMessageLoaded());

  //         debugPrint("읽음 처리 완료: 이전 미읽수 $previousUnreadCount개 감소됨");
  //       } catch (e) {
  //         debugPrint("❌ upsert 실패! 이유: $e");
  //         // Consider retrying or handling the error appropriately
  //       }
  //     }

  //     debugPrint("여기 엔터룸 끝났어용");
  //   } catch (e) {
  //     logger.e("enterRoom error: $e");
  //   }
  // }

  Future<void> enterRoom(String roomId) async {
    debugPrint("현재 채팅방 데이터:");
    for (var room in getChatList) {
      debugPrint("roomId: ${room.id}, roomName: ${room.roomName}");
    }

    try {
      currentRoomId = roomId;
      final unreadRoomMessages = messages[roomId]!
          .where((message) =>
              message.createdAt != null &&
              (readReceipts[roomId] == null ||
                  message.createdAt!.isAfter(readReceipts[roomId]!)))
          .toList();
      logger.d("readReceipts: ${readReceipts[roomId]}");
      logger.d("enterRoom: $unreadRoomMessages");
      final readReceiptsMap = unreadRoomMessages
          .map((message) => {
                'room_id': roomId,
                'message_id': message.id,
                'user_id': supabase.auth.currentUser!.id,
              })
          .toList();
      if (readReceiptsMap.isEmpty) return;
      await supabase.from('read_receipts').upsert(readReceiptsMap);
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
            ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 60));

      return compressedImage;
    } catch (e) {
      Analytics().logEvent("업로드_압축실패", parameters: {"에러": e.toString()});
      logger.e(e);
      return null;
    }
  }

  Future<String?> uploadImage(String roomId, XFile? otherFile) async {
    final session = supabase.auth.currentSession;
    if (session == null || session.isExpired) {
      await supabase.auth.refreshSession();
    }
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

      for (int retry = 0; retry < 3; retry++) {
        try {
          await supabase.storage
              .from('ImageMessages')
              .upload(imagePath, compressedImage)
              .timeout(const Duration(seconds: 5));
          return imagePath;
        } catch (e) {
          if (retry < 2) {
            logger.w("이미지 업로드 재시도 중... (${retry + 1}/3)");
            await Future.delayed(const Duration(milliseconds: 300));
            continue;
          }
          logger.e(e);
          Analytics().logEvent("업로드_이미지실패", parameters: {"에러": e.toString()});
          return null;
        }
      }
      return null;
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
      _selectedImage = null;
    } catch (e) {
      logger.e("sendImageMessage error: $e");
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
      debugPrint("그전 readReceipts: ${readReceipts[roomId]}");
      readReceipts[roomId] = DateTime.now();
      debugPrint("그후 readReceipts: ${readReceipts[roomId]}");
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
    challengeCubit.updateMission();
  }

  Future<void> loadImageMessages() async {
    if (chatList.isEmpty) {
      logger.w("⚠️ chatList가 비어있거나 이미 로딩 중입니다!");
      return;
    }

    try {
      // const baseUrl =
      //     'https://ccpcclfqofyvksajnrpg.supabase.co/storage/v1/object/public/ImageMessages/';

      for (final room in chatList) {
        final roomId = room.id;

        final ret = await supabase
            .from('messages')
            .select(
                "*, profiles!messages_user_id_fkey(*), chat_reactions(*), read_receipts(user_id)")
            .eq('room_id', roomId)
            .not('image_path', 'is', null)
            .not('user_id', 'in', blockedUsers)
            .not('id', 'in', blockedMessages)
            .order('created_at', ascending: false)
            .limit(32);

        // ✅ imageMessages에만 저장 + public URL 붙이기
        imageMessages[roomId] = ret
            .map((row) => Message.fromMap(
                  map: row,
                  myUserId: supabase.auth.currentUser!.id,
                  profile: Profile.fromMap(map: row['profiles']),
                  reactions: (row['chat_reactions'] as List<dynamic>)
                      .map((reactionRet) => Reaction.fromMap(map: reactionRet))
                      .toList(),
                  readReceipts: (row['read_receipts'] as List<dynamic>)
                      .map((receiptRet) => receiptRet['user_id'] as String)
                      .toSet(),
                ))
            .map((message) => message.copyWith(
                imageUrl: message.imagePath != null
                    ? '$baseUrl${message.imagePath}'
                    : null))
            .toList();

        logger.d("✅ 방 ID: $roomId의 이미지 메시지 처리 완료");
      }
    } catch (e) {
      logger.e("❌ loadImageMessages error: $e");
    } finally {
      _isLoadingMessages = false;
    }
  }

  // Future<void> loadImageMessages() async {
  //   if (chatList.isEmpty || _isLoadingMessages) {
  //     logger.w("⚠️ chatList가 비어있거나 이미 로딩 중입니다!");
  //     return;
  //   }

  //   try {
  //     _isLoadingMessages = true;

  //     for (final room in chatList) {
  //       final roomId = room.id;
  //       final ret = await supabase
  //           .from('messages')
  //           .select(
  //               "*, profiles!messages_user_id_fkey(*), chat_reactions(*), read_receipts(user_id)")
  //           .eq('room_id', roomId)
  //           .not('image_path', 'is', null) // image_path가 null이 아닌 것만
  //           .not('user_id', 'in', blockedUsers)
  //           .not('id', 'in', blockedMessages)
  //           .order('created_at', ascending: false)
  //           .limit(32);

  //       // ✅ 기존 이미지 메시지 초기화하고 새로 저장하기!
  //       imageMessages[roomId] = ret
  //           .map((row) => Message.fromMap(
  //                 map: row,
  //                 myUserId: supabase.auth.currentUser!.id,
  //                 profile: Profile.fromMap(map: row['profiles']),
  //                 reactions: (row['chat_reactions'] as List<dynamic>)
  //                     .map((reactionRet) => Reaction.fromMap(map: reactionRet))
  //                     .toList(),
  //                 readReceipts: (row['read_receipts'] as List<dynamic>)
  //                     .map((receiptRet) => receiptRet['user_id'] as String)
  //                     .toSet(),
  //               ))
  //           .toList();

  //       final roomMessages = imageMessages[roomId]!;
  //       for (var i = 0; i < roomMessages.length; i += 32) {
  //         final batch = roomMessages.skip(i).take(32).toList();

  //         await Future.wait(
  //           batch.map((message) async {
  //             if (message.imagePath != null) {
  //               try {
  //                 String? url;
  //                 for (int retry = 0; retry < 3; retry++) {
  //                   url = await _getSignedUrlWithRetry(message.imagePath!);
  //                   if (url != null) break;
  //                   if (retry < 2) {
  //                     logger.w("🔄 URL 생성 재시도 중... (${retry + 1}/3)");
  //                     await Future.delayed(
  //                         Duration(milliseconds: 300 * (retry + 1)));
  //                   }
  //                 }

  //                 if (url != null) {
  //                   imageMessages[roomId] =
  //                       List.from(imageMessages[roomId]!.map((m) {
  //                     if (m.id == message.id) {
  //                       return m.copyWith(imageUrl: url);
  //                     }
  //                     return m;
  //                   }));

  //                   if (messages.containsKey(roomId)) {
  //                     messages[roomId] = List.from(messages[roomId]!.map((m) {
  //                       if (m.id == message.id) {
  //                         return m.copyWith(imageUrl: url);
  //                       }
  //                       return m;
  //                     }));
  //                   }

  //                   // logger.d("✅ 메시지 ID: ${message.id}의 이미지 URL 생성 성공");
  //                 } else {
  //                   logger.e("❌ 메시지 ID: ${message.id}의 이미지 URL 생성 실패");
  //                 }
  //               } catch (e) {
  //                 logger.e("❌ 이미지 URL 생성 중 오류 발생: $e");
  //               }
  //             }
  //           }),
  //         );

  //         await Future.delayed(const Duration(milliseconds: 100));
  //       }

  //       logger.d("✅ 방 ID: $roomId의 이미지 메시지 처리 완료");
  //     }

  //     // emit(ChatMessageLoaded());
  //     logger.d("🎉 모든 이미지 메시지 로딩 완료!");
  //   } catch (e) {
  //     logger.e("❌ loadImageMessages error: $e");
  //   } finally {
  //     _isLoadingMessages = false;
  //   }
  // }

  Future<void> makeImageUrlImageMessage(Message message) async {
    if (message.imagePath != null) {
      // final baseUrl =
      //     'https://ccpcclfqofyvksajnrpg.supabase.co/storage/v1/object/public/ImageMessages/';
      final fullUrl = '$baseUrl${message.imagePath}';

      imageMessages[message.roomId] =
          List.from(imageMessages[message.roomId]!.map((m) {
        if (m.id == message.id) {
          m = message.copyWith(imageUrl: fullUrl);
        }
        return m;
      }));

      emit(ChatMessageLoaded());
    } else {
      logger.w("⚠️ [makeImageUrlImageMessage] imagePath가 null입니다. 재시도하겠습니다.");
    }
  }

  // Future<void> makeImageUrlImageMessage(Message message) async {
  //   if (message.imagePath != null) {
  //     try {
  //       final url = await _getSignedUrlWithRetry(message.imagePath!);

  //       if (url == null) {
  //         logger.e("⛔ Signed URL을 생성하지 못했습니다.");
  //         return;
  //       }
  //       imageMessages[message.roomId] =
  //           List.from(imageMessages[message.roomId]!.map((m) {
  //         if (m.id == message.id) {
  //           m = message.copyWith(imageUrl: url);
  //         }
  //         return m;
  //       }));

  //       emit(ChatMessageLoaded());
  //     } catch (e) {
  //       logger.e("⛔ makeImageUrl error: $e");
  //     }
  //   } else {
  //     logger.w("⚠️ [makeImageUrlImageMessage] imagePath가 null입니다. 재시도하겠습니다.");
  //   }
  // }

  Room getRoom(String roomId) =>
      chatList.firstWhere((element) => element.id == roomId);

  Profile? getProfile(String roomId, String userId) =>
      getRoom(roomId).memberMap[userId];

  List<Message> getMessagesByRoomId(String roomId) => messages[roomId] ?? [];
  List<Message> getImageMessagesByRoomId(String roomId) {
    final messages = imageMessages[roomId] ?? [];

    return messages;
  }

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
  Map<String, List<Message>> get getImageMessages => imageMessages;
}
