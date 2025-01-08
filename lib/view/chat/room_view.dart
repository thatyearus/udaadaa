import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/models/room.dart';
import 'package:udaadaa/view/chat/chat_view.dart';

class RoomView extends StatelessWidget {
  const RoomView({super.key});

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
            trailing:
                Text(rooms[index].lastMessage?.createdAt?.toString() ?? ''),
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
