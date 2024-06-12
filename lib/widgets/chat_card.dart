import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_chat/screens/chats.dart';

class ChatCard extends StatefulWidget {
  const ChatCard({super.key, required this.receiverUser});

  final Map<String, dynamic> receiverUser;

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>?> _getConversationStream() {
    final conversationId1 = '${currentUserId}_${widget.receiverUser['id']}';
    final conversationId2 = '${widget.receiverUser['id']}_${currentUserId}';

    final query1 =
        FirebaseFirestore.instance.collection('chats').doc(conversationId1);
    final query2 =
        FirebaseFirestore.instance.collection('chats').doc(conversationId2);

    return FirebaseFirestore.instance
        .collection('chats')
        .where(FieldPath.documentId,
            whereIn: [conversationId1, conversationId2])
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.isNotEmpty ? snapshot.docs.first : null);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> receiverUser = widget.receiverUser;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              return ChatScreen(receiverUser: receiverUser);
            },
          ));
        },
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
          stream: _getConversationStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const ListTile(
                leading: CircleAvatar(
                  radius: 27,
                  backgroundImage: NetworkImage(''),
                ),
                title: Text('Loading...'),
                subtitle: Text(''),
                trailing: Text(''),
              );
            }

            final conversationData = snapshot.data!.data();
            if (conversationData == null) {
              return const ListTile(
                leading: CircleAvatar(
                  radius: 27,
                  backgroundImage: NetworkImage(''),
                ),
                title: Text('No Data'),
                subtitle: Text(''),
                trailing: Text(''),
              );
            }

            final lastMessage = conversationData['lastMessage'] ?? '';
            final lastUpdatedAt =
                (conversationData['lastUpdatedAt'] as Timestamp?)?.toDate();
            final formattedTime = lastUpdatedAt != null
                ? DateFormat('HH:mm').format(lastUpdatedAt)
                : '';

            return ListTile(
              leading: CircleAvatar(
                radius: 27,
                backgroundImage: NetworkImage(receiverUser['image_url']),
              ),
              title: Text(receiverUser['username']),
              subtitle: Text(
                lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                formattedTime,
                style: const TextStyle(color: Colors.black54),
              ),
            );
          },
        ),
      ),
    );
  }
}
