import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_chat/providers/chat_provider.dart';
import 'package:test_chat/widgets/chat_messages.dart';
import 'package:test_chat/widgets/new_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.receiverUser});

  final Map<String, dynamic> receiverUser;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.checkConversationExists(widget.receiverUser['id']);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> receiverUser = widget.receiverUser;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                receiverUser['image_url'],
              ),
              radius: 22,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${receiverUser['username']} ${receiverUser['surname']}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
                const Text(
                  // ignore: dead_code
                  true ? 'В сети' : '',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatMessages(
              receiverUser: receiverUser,
            ),
          ),
          NewMessage(
            receiverUser: receiverUser,
          ),
        ],
      ),
    );
  }
}
