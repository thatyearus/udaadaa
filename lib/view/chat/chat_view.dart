import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';

import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/cubit/form_cubit.dart';
import 'package:udaadaa/models/message.dart';
import 'package:udaadaa/models/room.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/chat/image_detail_view.dart';
import 'package:udaadaa/view/chat/image_list_view.dart';
import 'package:udaadaa/view/chat/profile_view.dart';
import 'package:udaadaa/view/chat/ranking_view.dart';
import 'package:udaadaa/view/form/exercise/exercise_first_view.dart';
import 'package:udaadaa/view/form/weight/weight_first_view.dart';
import 'package:udaadaa/view/onboarding/first_view.dart';
import 'package:udaadaa/widgets/chat_bubble.dart';

/// Page to chat with someone.
///
/// Displays chat bubbles as a ListView and TextField to enter new chat.
class ChatView extends StatefulWidget {
  const ChatView({super.key, required this.roomInfo, this.fromPush = false});

  /*static Route<void> route(String roomId) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider<ChatCubit>(
        create: (context) => ChatCubit()..setMessagesListener(roomId),
        child: const ChatPage(),
      ),
    );
  }*/
  final bool fromPush;
  final Room roomInfo;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  bool isLoadingMore = false;
  bool hasMore = true;
  DateTime? oldestMessageCreatedAt;
  List<Message> _currentMessages = [];

  @override
  void initState() {
    super.initState();
    _initializeMessages();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeMessages() async {
    final messages =
        context.read<ChatCubit>().getMessagesByRoomId(widget.roomInfo.id);
    setState(() {
      _currentMessages = messages;
    });
  }

  Future<void> loadMoreWrapper() async {
    await context.read<ChatCubit>().loadMoreMessages();
    isLoadingMore = false;
  }

  Drawer showDrawer(BuildContext context) {
    // List<Message> imageMessages = context.select<ChatCubit, List<Message>>(
    //     (cubit) => cubit
    //         .getMessagesByRoomId(widget.roomInfo.id)
    //         .where((element) => element.imageUrl != null)
    //         .toList());
    List<Message> imageMessages = context.select<ChatCubit, List<Message>>(
        (cubit) => cubit.getImageMessagesByRoomId(widget.roomInfo.id));

    List<String> blockedUsers = context
        .select<ChatCubit, List<String>>((cubit) => cubit.getBlockedUsers);
    Map<String, bool> pushOptions = context
        .select<ChatCubit, Map<String, bool>>((cubit) => cubit.getPushOptions);
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            minimum: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.roomInfo.roomName,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text('${widget.roomInfo.members.length}명 참여중',
                    style: Theme.of(context).textTheme.bodyLarge),
                /*Text("채팅방 일자: ${roomInfo.createdAt}",
                    style: Theme.of(context).textTheme.bodyMedium),*/
              ],
            ),
          ),
          Divider(color: AppColors.neutral[200]),
/*
          DrawerHeader(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roomInfo.roomName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text('${roomInfo.members.length}명 참여중',
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),*/
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            title:
                Text('사진 모아보기', style: Theme.of(context).textTheme.titleSmall),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.neutral[500]),
            onTap: () {
              Analytics().logEvent('채팅_사진모아보기',
                  parameters: {'room_id': widget.roomInfo.id});
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ImageListView(
                    roomInfo: widget.roomInfo,
                    imageMessages: imageMessages,
                  ),
                ),
              );
            },
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppSpacing.xxs,
            ),
            itemCount: min(imageMessages.length, 3),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ImageDetailView(
                        roomInfo: widget.roomInfo,
                        imageMessage: imageMessages[index],
                      ),
                    ),
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: imageMessages[index].imageUrl!,
                  fit: BoxFit.cover, // or contain
                  maxWidthDiskCache: 512,
                  maxHeightDiskCache: 512,
                  memCacheHeight: 512,
                  memCacheWidth: 512,
                  placeholder: (context, url) => const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error_outline),
                ),

                // child: CachedNetworkImage(
                //   imageUrl: imageMessages[index].imageUrl!,
                //   fit: BoxFit.cover,
                // ),
              );
            },
          ),
          AppSpacing.verticalSizedBoxXs,
          Divider(color: AppColors.neutral[200]),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Text('참여자 목록', style: Theme.of(context).textTheme.titleSmall),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: widget.roomInfo.members.length,
              itemBuilder: (context, index) {
                bool isBlocked =
                    blockedUsers.contains(widget.roomInfo.members[index].id);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (isBlocked
                        ? AppColors.neutral[200]
                        : AppColors.primary[50]),
                    child: Icon(Icons.person,
                        color: (isBlocked
                            ? AppColors.neutral[500]
                            : AppColors.primary)),
                  ),
                  title: Text(widget.roomInfo.members[index].nickname,
                      style: Theme.of(context).textTheme.bodyMedium),
                  trailing: (widget.roomInfo.members[index].id ==
                          supabase.auth.currentUser!.id)
                      ? Container(
                          padding: AppSpacing.edgeInsetsXs,
                          decoration: BoxDecoration(
                            color: AppColors.primary[50],
                            borderRadius: BorderRadius.circular(AppSpacing.s),
                          ),
                          child: Text(
                            "나",
                            style: AppTextStyles.bodyMedium(
                              TextStyle(color: AppColors.primary[500]),
                            ),
                          ),
                        )
                      : (isBlocked)
                          ? Container(
                              padding: AppSpacing.edgeInsetsXs,
                              decoration: BoxDecoration(
                                color: AppColors.neutral[200],
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.s),
                              ),
                              child: Text(
                                "차단됨",
                                style: AppTextStyles.bodyMedium(
                                  TextStyle(color: AppColors.neutral[500]),
                                ),
                              ),
                            )
                          : null,
                  onTap: () {
                    Analytics().logEvent('채팅_참여자프로필', parameters: {
                      'user_id': widget.roomInfo.members[index].id
                    });
                    navigateToProfileView(
                      context,
                      widget.roomInfo.members[index].nickname,
                      widget.roomInfo.members[index].id,
                    );
                  },
                );
              },
            ),
          ),
          Divider(color: AppColors.neutral[200]),
          ListTile(
            leading: (widget.roomInfo.endDay != null)
                ? IconButton(
                    icon: Icon(Icons.leaderboard_rounded,
                        color: AppColors.neutral[500]),
                    onPressed: () {
                      Analytics().logEvent('채팅_랭킹확인',
                          parameters: {'room_id': widget.roomInfo.id});
                      context
                          .read<ChatCubit>()
                          .fetchRoomRanking(widget.roomInfo);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RankingView(
                            roomId: widget.roomInfo.id,
                          ),
                        ),
                      );
                    },
                    /*onPressed: () async {
                  await SendbirdSdk().disconnect();
                  await supabase.Supabase.instance.client.auth.signOut();
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('user');
                  await prefs.remove('group_channel');
                  await prefs.remove('personal_channel');
                  await prefs.remove('entrance_code');
                  Navigator.popAndPushNamed(context, '/entrance');
                }*/
                  )
                : null,
            trailing: IconButton(
              icon: /*Icon(_pushTriggerOption == GroupChannelPushTriggerOption.off
                  ? Icons.notifications_off
                  : Icons.notifications_active),*/

                  Icon(
                      pushOptions[widget.roomInfo.id] == true
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: AppColors.neutral[500]),
              //  onPressed: _toogglePushOption,
              onPressed: () {
                Analytics().logEvent('채팅_푸시알림설정', parameters: {
                  'room_id': widget.roomInfo.id,
                  'push_option': pushOptions[widget.roomInfo.id]!.toString(),
                });
                context.read<ChatCubit>().togglePushOption(
                    widget.roomInfo.id, !pushOptions[widget.roomInfo.id]!);
              },
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    final missionName = ["아침", "점심", "저녁", "간식", "체중", "운동"];
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.s),
                child: Text('인증하기', style: AppTextStyles.textTheme.titleMedium),
              ),
              Divider(color: AppColors.neutral[200]),
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                  //crossAxisSpacing: 2.0,
                  // mainAxisSpacing: 2.0,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.xs),
                                border: Border.all(
                                    color: AppColors.neutral[400]!, width: 2),
                              ),
                              child: Icon(Icons.add,
                                  color: AppColors.neutral[400], size: 40),
                            ),
                          ],
                        ),
                        onPressed: () {
                          Analytics().logEvent('채팅_인증하기',
                              parameters: {'mission': missionName[index]});
                          // context.read<ChatCubit>().sendMessage();
                          // _showBottomSheet(context);
                          // context.read<ChatCubit>().missionComplete();
                          if (index < 4) {
                            context
                                .read<FormCubit>()
                                .updateMealSelection(index);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const FirstView(),
                              ),
                            );
                          } else if (index == 4) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const WeightFirstView(),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ExerciseFirstView(),
                              ),
                            );
                          }
                        },
                      ),
                      AppSpacing.verticalSizedBoxXxs,
                      Text(
                        missionName[index],
                        style: AppTextStyles.textTheme.bodyLarge,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // showTutorial(context);
    // final messages = context.select<ChatCubit, List<Message>>(
    //     (cubit) => cubit.getMessagesByRoomId(widget.roomInfo.id));
    final userName = context.select<AuthCubit, String>(
        (cubit) => cubit.getCurProfile?.nickname ?? "");
    final personalChannel =
        (widget.roomInfo.endDay == null && widget.roomInfo.startDay == null);
    final enabled = personalChannel ||
        (widget.roomInfo.endDay!
                .add(Duration(days: 1))
                .isAfter(DateTime.now()) &&
            widget.roomInfo.startDay!
                .subtract(Duration(days: 1))
                .isBefore(DateTime.now()));

    return BlocListener<ChatCubit, ChatState>(
      listener: (context, state) {
        if (state is ChatMessageLoaded) {
          final messages =
              context.read<ChatCubit>().getMessagesByRoomId(widget.roomInfo.id);
          setState(() {
            _currentMessages = messages;
          });
        }
      },
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            context.read<ChatCubit>().leaveRoom(widget.roomInfo.id);
          }
        },
        canPop: !isLoadingMore,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.roomInfo.roomName,
              style: AppTextStyles.textTheme.headlineLarge,
            ),
            backgroundColor: AppColors.primary[100],
            surfaceTintColor: AppColors.primary[100],
            centerTitle: true,
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu_rounded, color: AppColors.neutral[800]),
                  onPressed: () {
                    Analytics().logEvent('채팅_메뉴버튼클릭');
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
              ),
            ],
          ),
          endDrawer: showDrawer(context),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s, vertical: AppSpacing.xxs),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.25),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(FluentIcons.megaphone_24_regular,
                        color: AppColors.neutral[500]),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.s),
                        child: Text(
                          personalChannel
                              ? '궁금한 점이 있으시면 언제든지 이 채널로 문의해주세요.'
                              : '우측 하단의 + 버튼을 눌러 인증을 진행해 주세요.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollUpdateNotification &&
                        scrollNotification.scrollDelta != null &&
                        scrollNotification.scrollDelta! > 0 &&
                        scrollNotification.metrics.pixels >=
                            scrollNotification.metrics.maxScrollExtent - 100) {
                      if (!isLoadingMore) {
                        debugPrint('📦 거의 맨 아래입니다! 이전 메시지 불러오기');
                        isLoadingMore = true;
                        loadMoreWrapper();
                      }
                    }
                    return false;
                  },
                  child: DashChat(
                    currentUser:
                        asDashChatUser(supabase.auth.currentUser!.id, userName),
                    inputOptions: InputOptions(
                        inputDisabled: !enabled,
                        sendOnEnter: false,
                        textInputAction: TextInputAction.newline,
                        inputMaxLines: 2,
                        inputToolbarMargin: EdgeInsets.zero,
                        inputToolbarPadding: const EdgeInsets.all(2),
                        inputToolbarStyle:
                            BoxDecoration(color: AppColors.white, boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, -4),
                          ),
                        ]),
                        inputTextStyle: Theme.of(context).textTheme.bodyMedium,
                        inputDecoration: InputDecoration(
                          isDense: true,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.m),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.m),
                            borderSide: BorderSide.none,
                          ),
                          hintText: '메시지를 입력하세요',
                          hintStyle: AppTextStyles.bodyMedium(
                            TextStyle(color: AppColors.neutral[500]),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s,
                            vertical: AppSpacing.xs,
                          ),
                          filled: true,
                          fillColor: AppColors.neutral[50],
                        ),
                        leading: [
                          enabled
                              ? IconButton(
                                  icon: Icon(Icons.photo_outlined,
                                      color: AppColors.neutral[500]),
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    Future.delayed(
                                        const Duration(milliseconds: 100), () {
                                      if (!context.mounted) return;
                                      Analytics().logEvent('채팅_사진전송');
                                      context
                                          .read<ChatCubit>()
                                          .sendImageMessage(widget.roomInfo.id);
                                    });
                                  },
                                )
                              : Container(
                                  padding: const EdgeInsets.all(2),
                                ),
                        ],
                        trailing: [
                          (!personalChannel && enabled)
                              ? IconButton(
                                  icon: Stack(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              AppSpacing.xs),
                                          border: Border.all(
                                              color: AppColors.neutral[500]!,
                                              width: 1),
                                        ),
                                        child: Icon(Icons.add,
                                            color: AppColors.neutral[500],
                                            size: 20),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    Analytics().logEvent('채팅_인증하기_버튼클릭');
                                    _showBottomSheet(context);
                                  },
                                )
                              : Container(
                                  padding: const EdgeInsets.all(2),
                                ),
                        ]),
                    messageListOptions: MessageListOptions(
                      dateSeparatorBuilder: (date) => Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(
                          top: AppSpacing.m,
                          bottom: AppSpacing.xxs,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.neutral[800]?.withAlpha(100),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s,
                            vertical: 6,
                          ),
                          child: Text(
                            '${date.year}년 ${date.month}월 ${date.day}일',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ),
                    ),
                    messageOptions: MessageOptions(
                      showCurrentUserAvatar: false,
                      showOtherUsersAvatar: true,
                      messageRowBuilder: (ChatMessage message,
                          ChatMessage? previousMessage,
                          ChatMessage? nextMessage,
                          bool isAfterDateSeparator,
                          bool isBeforeDateSeparator) {
                        bool isFirstInSequence = previousMessage == null ||
                            previousMessage.user.id != message.user.id ||
                            isAfterDateSeparator;
                        bool isLastInSequence = nextMessage == null ||
                            nextMessage.user.id != message.user.id ||
                            isBeforeDateSeparator;

                        bool isLastInRoom = nextMessage == null;

                        return ChatBubble(
                          message: message,
                          isMine: message.customProperties?['message'].isMine,
                          isFirstInSequence: isFirstInSequence,
                          isLastInSequence: isLastInSequence,
                          memberCount: widget.roomInfo.members.length,
                          isLastInRoom: isLastInRoom,
                          isDeletedMessage:
                              message.customProperties?['isDeletedMessage'],
                          createdAt: message.customProperties?['createdAt'],
                        );
                      },
                    ),
                    onSend: (ChatMessage message) {
                      Analytics().logEvent('채팅_메시지전송', parameters: {
                        'room_id': widget.roomInfo.id,
                        'message': message.text,
                      });
                      context.read<ChatCubit>().sendMessage(
                          message.text, "textMessage", widget.roomInfo.id);
                    },
                    messages: asDashChatMessages(_currentMessages),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ChatUser asDashChatUser(String userId, String firstName) {
    return ChatUser(
      id: userId,
      firstName: firstName,
    );
  }

  List<ChatMessage> asDashChatMessages(List<Message> messages) {
    List<ChatMessage> result = [];
    for (var message in messages) {
      String user = message.userId;
      // Profile profile = message.profile;
      if (message.isDeleted == true) {
        result.add(
          ChatMessage(
              createdAt: message.createdAt!,
              text: "삭제된 메시지입니다.",
              user: asDashChatUser(user, message.profile?.nickname ?? user),
              customProperties: {
                // 'reactions': message.reactions,
                'messageId': message.id,
                'channelUrl': message.roomId,
                // 'unreadCount': message.readReceipts.length,
                'message': message,
                'isDeletedMessage': true,
                'createdAt': message.createdAt,
              }),
        );
      } else if (message.type == "textMessage") {
        result.add(
          ChatMessage(
              createdAt: message.createdAt!,
              text: message.content ?? "",
              user: asDashChatUser(user, message.profile?.nickname ?? user),
              customProperties: {
                // 'reactions': message.reactions,
                'messageId': message.id,
                'channelUrl': message.roomId,
                // 'unreadCount': message.readReceipts.length,
                'message': message,
                'createdAt': message.createdAt,
              }),
        );
      } else if (message.type == "imageMessage") {
        result.add(
          ChatMessage(
              createdAt: message.createdAt!,
              user: asDashChatUser(user, message.profile?.nickname ?? user),
              medias: (message.imageUrl != null
                  ? [
                      ChatMedia(
                        url: message.imageUrl!,
                        fileName: "사진",
                        type: MediaType.image,
                      )
                    ]
                  : []),
              customProperties: {
                // 'reactions': message.reactions,
                'messageId': message.id,
                'channelUrl': message.roomId,
                // 'unreadCount': message.readReceipts.length,
                'message': message,
                'createdAt': message.createdAt,
              }),
        );
      } else if (message.type == 'missionMessage') {
        result.add(
          ChatMessage(
              createdAt: message.createdAt!,
              user: asDashChatUser(user, message.profile?.nickname ?? user),
              text: message.content ?? "",
              medias: (message.imageUrl != null
                  ? [
                      ChatMedia(
                        url: message.imageUrl!,
                        fileName: "사진",
                        type: MediaType.image,
                      )
                    ]
                  : []),
              customProperties: {
                // 'reactions': message.reactions,
                'messageId': message.id,
                'channelUrl': message.roomId,
                // 'unreadCount': message.readReceipts.length,
                'message': message,
                'createdAt': message.createdAt,
              }),
        );
      }
    }

    return result;
  }
}
