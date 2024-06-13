import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:test_chat/providers/chat_provider.dart';

class VoiceMessage extends StatefulWidget {
  const VoiceMessage({super.key, required this.receiverUser});
  final Map<String, dynamic> receiverUser;

  @override
  State<VoiceMessage> createState() {
    return _VoiceMessageState();
  }
}

class _VoiceMessageState extends State<VoiceMessage> {
  final _record = AudioRecorder();
  Timer? _timer;
  int _time = 0;
  bool _isRecording = true;
  late String _audioPath;

  @override
  void initState() {
    super.initState();
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      setState(() {
        _time++;
      });
    });
  }

  Future<void> _start() async {
    try {
      if (await _record.hasPermission()) {
        Directory? dir;

        if (Platform.isIOS) {
          dir = await getApplicationDocumentsDirectory();
        } else {
          dir = await getExternalStorageDirectory();
        }
        const config = RecordConfig();

        final filePath =
            '${dir?.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _record.start(config, path: filePath);
        _audioPath = filePath;
      }
    } catch (e) {
      print('Error : $e');
    }
  }

  Future<void> _stop() async {
    await _record.stop();
    if (_audioPath.isNotEmpty) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.sendVoiceMessage(
          widget.receiverUser['id'], _audioPath);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _record.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (_isRecording) {
          _startTimer();
          _start();
          setState(() {
            _isRecording = false;
          });
        } else {
          _stop();
          _timer?.cancel();
          setState(() {
            _isRecording = true;
            _time = 0;
          });
        }
      },
      icon: _isRecording
          ? const Icon(Icons.mic)
          : Column(
              children: [
                const Icon(Icons.stop, size: 20),
                Text(
                  formattedTime(timeInSecond: _time),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
    );
  }
}

String formattedTime({required int timeInSecond}) {
  int sec = timeInSecond % 60;
  int min = (timeInSecond / 60).floor();
  String minute = min.toString().padLeft(2, '0');
  String seconds = sec.toString().padLeft(2, '0');

  return '$minute:$seconds';
}
