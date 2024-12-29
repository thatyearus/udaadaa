import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:image_picker/image_picker.dart';
import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/models/message.dart';
import 'package:udaadaa/widgets/chat_bubble.dart';

/// Page to chat with someone.
///
/// Displays chat bubbles as a ListView and TextField to enter new chat.
class ChatView extends StatelessWidget {
  const ChatView({super.key});

  /*static Route<void> route(String roomId) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider<ChatCubit>(
        create: (context) => ChatCubit()..setMessagesListener(roomId),
        child: const ChatPage(),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    final messages =
        context.select<ChatCubit, List<Message>>((cubit) => cubit.getMessages);
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ChatBubble(
                  message: message,
                  isFirstInSequence: true,
                  isLastInSequence: true,
                );
              },
            ),
          ),
          const _MessageBar(),
        ],
      ),
    );
  }
}

/// Set of widget that contains TextField and Button to submit message
class _MessageBar extends StatefulWidget {
  const _MessageBar();

  @override
  State<_MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<_MessageBar> {
  late final TextEditingController _textController;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: EdgeInsets.only(
          top: 8,
          left: 8,
          right: 8,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => _submitFileMessage(),
              icon: const Icon(Icons.album),
            ),
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.text,
                maxLines: null,
                autofocus: true,
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Type a message',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.all(8),
                ),
              ),
            ),
            TextButton(
              onPressed: () => _submitMessage(),
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final text = _textController.text;
    if (text.isEmpty) {
      return;
    }
    // BlocProvider.of<ChatCubit>(context).sendMessage(text);
    _textController.clear();
  }

  void _submitFileMessage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) {
        return;
      }

      // BlocProvider.of<ChatCubit>(context).sendFileMessage(File(image.path));
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
