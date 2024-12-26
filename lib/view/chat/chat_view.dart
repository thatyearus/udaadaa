import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/models/message.dart';

class ChatView extends StatelessWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Message> messages =
        context.select((ChatCubit cubit) => cubit.getMessages);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(messages[index].content ?? ""),
            subtitle: Text(messages[index].createdAt.toString()),
          );
        },
      ),
    );
  }
}
