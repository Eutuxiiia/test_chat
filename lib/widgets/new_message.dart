import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_chat/providers/chat_provider.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({Key? key, required this.receiverUser}) : super(key: key);

  final Map<String, dynamic> receiverUser;

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      isTyping = _messageController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text.trim();
    if (enteredMessage.isEmpty) {
      return;
    }
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.sendMessage(widget.receiverUser['id'], enteredMessage);

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              color: const Color.fromARGB(255, 237, 242, 246),
            ),
            child: IconButton(
              color: Colors.black,
              onPressed: () {
                // Handle attachment action
              },
              icon: const Icon(Icons.attachment),
              iconSize: 30,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromARGB(255, 237, 242, 246),
              ),
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  border: InputBorder.none,
                  hintText: 'Сообщение',
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              color: const Color.fromARGB(255, 237, 242, 246),
            ),
            child: IconButton(
              color: Colors.black,
              onPressed: _submitMessage,
              icon: isTyping ? const Icon(Icons.send) : const Icon(Icons.mic),
              iconSize: isTyping ? 25 : 30,
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }
}
