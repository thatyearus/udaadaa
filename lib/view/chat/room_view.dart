import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/models/room.dart';
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
            trailing: Text(rooms[index].lastMessage != null
                ? _formatTimestamp(rooms[index].lastMessage?.createdAt)
                : ''),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatView(
                    roomInfo: rooms[index],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
