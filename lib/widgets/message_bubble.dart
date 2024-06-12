import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.time,
    required this.isRead,
  });

  final String message;
  final bool isMe;
  final String time;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  ChatBubble(
                    clipper: ChatBubbleClipper9(
                        type: isMe
                            ? BubbleType.sendBubble
                            : BubbleType.receiverBubble),
                    alignment: Alignment.topRight,
                    margin: const EdgeInsets.only(bottom: 7),
                    backGroundColor: isMe
                        ? const Color.fromARGB(255, 60, 237, 120)
                        : const Color.fromARGB(255, 237, 242, 246),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Text(
                              message,
                              style: const TextStyle(
                                height: 1.3,
                                color: Colors.black87,
                              ),
                              softWrap: true,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 3),
                        isRead
                            ? const Icon(
                                Icons.done_all,
                                size: 15,
                                color: Colors.black,
                              )
                            : const Icon(
                                Icons.done,
                                size: 15,
                                color: Colors.black,
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
