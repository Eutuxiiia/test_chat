import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:just_audio/just_audio.dart';

class VoiceMessageBubble extends StatefulWidget {
  const VoiceMessageBubble({
    super.key,
    required this.isMe,
    required this.time,
    required this.isRead,
    required this.voiceUrl,
  });

  final bool isMe;
  final String time;
  final bool isRead;
  final String voiceUrl;

  @override
  State<VoiceMessageBubble> createState() {
    return _VoiceMessageBubbleState();
  }
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.playerStateStream.listen((playerState) {
      final playing = playerState.playing;
      final processingState = playerState.processingState;

      if (!playing && processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  void _togglePlayPause() async {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      await _audioPlayer.setUrl(widget.voiceUrl);
      await _audioPlayer.play();
    } else {
      await _audioPlayer.pause();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Column(
            crossAxisAlignment:
                widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              ChatBubble(
                clipper: ChatBubbleClipper9(
                  type: widget.isMe
                      ? BubbleType.sendBubble
                      : BubbleType.receiverBubble,
                ),
                alignment: widget.isMe ? Alignment.topRight : Alignment.topLeft,
                margin: const EdgeInsets.only(bottom: 5),
                backGroundColor: widget.isMe
                    ? const Color.fromARGB(255, 60, 237, 120)
                    : const Color.fromARGB(255, 237, 242, 246),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.play_arrow,
                              color: Colors.black,
                              size: 30,
                            ),
                            onPressed: _togglePlayPause,
                          ),
                          const Text(
                            'Voice message',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            widget.time,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 3),
                          widget.isRead
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
