import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.time,
    required this.isRead,
    required this.messageType,
  });

  final String message;
  final bool isMe;
  final String time;
  final bool isRead;
  final String messageType;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              ChatBubble(
                clipper: ChatBubbleClipper9(
                  type:
                      isMe ? BubbleType.sendBubble : BubbleType.receiverBubble,
                ),
                alignment: isMe ? Alignment.topRight : Alignment.topLeft,
                margin: const EdgeInsets.only(bottom: 7),
                backGroundColor: isMe
                    ? const Color.fromARGB(255, 60, 237, 120)
                    : const Color.fromARGB(255, 237, 242, 246),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      messageType == 'text'
                          ? Text(
                              message,
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.start,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    messageType,
                                    fit: BoxFit.cover,
                                    width: 250,
                                    height: 150,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  message,
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
