import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatCard extends StatefulWidget {
  final User user;

  const ChatCard({super.key, required this.user});

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {},
        child: const ListTile(
          leading: CircleAvatar(),
          title: Text('Bakytzhan'),
          subtitle: Text(
            'Text',
            maxLines: 1,
          ),
          trailing: Text(
            'Chat',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );
  }
}
