import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:badges/badges.dart' as badges;
import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/models/room.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/chat/chat_view.dart';

class RoomView extends StatelessWidget {
  const RoomView({super.key});

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final isToday = now.year == timestamp.year &&
        now.month == timestamp.month &&
        now.day == timestamp.day;

    if (isToday) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.month.toString().padLeft(2, '0')}월 ${timestamp.day.toString().padLeft(2, '0')}일';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Room> rooms = context.select((ChatCubit cubit) => cubit.getChatList);
    Map<String, int> unreadCount =
        context.select((ChatCubit cubit) => cubit.getUnreadMessages);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(rooms[index].roomName),
            subtitle: Text(rooms[index].lastMessage?.content ??
                (rooms[index].lastMessage?.imagePath != null ? '사진' : '')),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  rooms[index].lastMessage != null
                      ? _formatTimestamp(rooms[index].lastMessage?.createdAt)
                      : '',
                  style: AppTextStyles.labelSmall(
                    TextStyle(color: AppColors.neutral[500]),
                  ),
                ),
                if (unreadCount[rooms[index].id] != null &&
                    unreadCount[rooms[index].id]! > 0)
                  badges.Badge(
                    badgeContent: Text(
                      unreadCount[rooms[index].id].toString(),
                      style: AppTextStyles.labelSmall(
                        const TextStyle(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatView(
                    roomInfo: rooms[index],
                  ),
                ),
              );
              context.read<ChatCubit>().enterRoom(rooms[index].id);
            },
          );
        },
      ),
    );
  }
}
