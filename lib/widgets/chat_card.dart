import 'package:flutter/material.dart';

class ChatCard extends StatefulWidget {
  const ChatCard({super.key, required this.user});

  final Map<String, dynamic> user;

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> user = widget.user;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {},
        child: ListTile(
          leading: CircleAvatar(
            radius: 27,
            backgroundImage: NetworkImage(user['image_url']),
          ),
          title: Text(user['username']),
          subtitle: const Text(
            'Text',
            maxLines: 1,
          ),
          trailing: const Text(
            'Chat',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );
  }
}
