import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:test_chat/providers/chat_provider.dart';
import 'package:test_chat/widgets/message_bubble.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({Key? key, required this.receiverUser}) : super(key: key);

  final Map<String, dynamic> receiverUser;

  Future<DocumentSnapshot<Map<String, dynamic>>> _getDocument(
      String currentUserId, String receiverId) async {
    final doc1 = FirebaseFirestore.instance
        .collection('chats')
        .doc('${currentUserId}_$receiverId');

    final doc2 = FirebaseFirestore.instance
        .collection('chats')
        .doc('${receiverId}_$currentUserId');

    final snapshot1 = await doc1.get();
    final snapshot2 = await doc2.get();

    if (snapshot1.exists) {
      return snapshot1;
    } else {
      return snapshot2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final currentUserId = chatProvider.currentUser!.uid;

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _getDocument(currentUserId, receiverUser['id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text('Сообщений не найдено'),
          );
        }

        final docId = snapshot.data!.id;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .doc(docId)
              .collection('messages')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('Сообщений не найдено'),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Что-то пошло не так'),
              );
            }

            final allMessages = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.only(
                right: 5,
                left: 5,
                bottom: 40,
              ),
              reverse: true,
              itemCount: allMessages.length,
              itemBuilder: (ctx, index) {
                final chatMessage =
                    allMessages[index].data() as Map<String, dynamic>?;

                if (chatMessage == null) {
                  return SizedBox.shrink();
                }

                final senderId = chatMessage['sendId'];
                final receiverId = chatMessage['receiverId'];

                final isSenderToReceiver = senderId == currentUserId &&
                    receiverId == receiverUser['id'];
                final isReceiverToSender = senderId == receiverUser['id'] &&
                    receiverId == currentUserId;

                if (isReceiverToSender) {
                  if (chatMessage['read'] == false) {
                    FirebaseFirestore.instance
                        .collection('chats')
                        .doc(docId)
                        .collection('messages')
                        .doc(allMessages[index].id)
                        .update({'read': true});
                  }
                }

                if (isSenderToReceiver || isReceiverToSender) {
                  final messageTime = chatMessage['createdAt'].toDate();

                  final formattedTime = DateFormat('HH:mm').format(messageTime);

                  return MessageBubble(
                    message: chatMessage['text'],
                    isMe: senderId == currentUserId,
                    time: formattedTime,
                    isRead: chatMessage['read'],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            );
          },
        );
      },
    );
  }
}
