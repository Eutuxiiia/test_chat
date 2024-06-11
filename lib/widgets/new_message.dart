import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final _enteredMessage = _messageController.text;

    if (_enteredMessage.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();

    final user = FirebaseAuth.instance.currentUser!;

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    FirebaseFirestore.instance.collection('chat').add({
      'text': _enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'userName': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
    });

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
              onPressed: _submitMessage,
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
                // Add border to TextField
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
              icon: const Icon(Icons.mic),
              iconSize: 30,
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }
}
