import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:test_chat/providers/chat_provider.dart';
import 'package:test_chat/widgets/voice_message.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key, required this.receiverUser});
  final Map<String, dynamic> receiverUser;

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();
  bool isTyping = false;
  File? _imageFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      isTyping = _messageController.text.isNotEmpty;
    });
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text.trim();
    if (enteredMessage.isEmpty && _imageFile == null) {
      return;
    }
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (_imageFile != null) {
      final imageUrl = await _uploadImageToStorage();
      await chatProvider.sendMessage(
        widget.receiverUser['id'],
        enteredMessage,
        imageUrl,
      );
    } else {
      await chatProvider.sendMessage(
        widget.receiverUser['id'],
        enteredMessage,
        'text',
      );
    }

    _messageController.clear();
    setState(() {
      _imageFile = null;
    });
  }

  Future<String> _uploadImageToStorage() async {
    final firebase_storage.Reference storageRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('chat_images')
        .child('${DateTime.now().toIso8601String()}.jpg');
    final firebase_storage.UploadTask uploadTask =
        storageRef.putFile(_imageFile!);
    final firebase_storage.TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
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
            child: _imageFile != null
                ? Image.file(
                    _imageFile!,
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                  )
                : IconButton(
                    color: Colors.black,
                    onPressed: _pickImage,
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
            child: isTyping
                ? IconButton(
                    color: Colors.black,
                    onPressed: _submitMessage,
                    icon: const Icon(Icons.send),
                    iconSize: 25,
                  )
                : VoiceMessage(
                    receiverUser: widget.receiverUser,
                  ),
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }
}
