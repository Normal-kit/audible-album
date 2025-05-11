import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class RecordResultpage extends StatefulWidget {
  const RecordResultpage({super.key});

  @override
  State<RecordResultpage> createState() => _RecordResultpageState();
}

class _RecordResultpageState extends State<RecordResultpage> {
  String? imagePath;
  String? gptResult;
  String? audioPath;
  String? timestamp;

  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player.openPlayer();
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  Future<void> _playAudio() async {
    if (audioPath == null) return;

    if (_isPlaying) {
      await _player.stopPlayer();
    } else {
      final status = await Permission.microphone.request();
      if (!status.isGranted) return;

      await _player.startPlayer(
        fromURI: audioPath,
        codec: Codec.aacADTS,
        whenFinished: () {
          setState(() => _isPlaying = false);
        },
      );
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _saveResult() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/saved_result.json');

    final data = {
      'imagePath': imagePath,
      'gptResult': gptResult,
      'audioPath': audioPath,
      'timestamp': timestamp,
    };

    await file.writeAsString(jsonEncode(data));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Result saved at: ${file.path}'),
        duration: const Duration(seconds: 4),
      ),
    );

    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;

    // Only set values if they are null to prevent re-initialization
    if (imagePath == null && args != null) {
      imagePath = args['imagePath'] as String?;
      gptResult = args['gptResult'] as String?;
      audioPath = args['audioPath'] as String?;
      timestamp = args['timestamp'] as String?;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (imagePath != null) Image.file(File(imagePath!)),
            const SizedBox(height: 16),
            if (gptResult != null)
              Text('GPT Analysis Result: $gptResult', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            if (timestamp != null)
              Text('Recording Time: $timestamp', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Semantics(
                  label: 'Re-record the audio',
                  hint: '재녹음 버튼, 녹음 화면으로 돌아갑니다.',
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/record',
                        arguments: {
                          'imagePath': imagePath,
                          'gptResult': gptResult,
                        },
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Re-record'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ),
                Semantics(
                  label: _isPlaying ? 'Stop audio playback' : 'Play audio',
                  hint: _isPlaying
                      ? '재생을 중지합니다.'
                      : '녹음된 파일을 재생합니다.',
                  child: ElevatedButton.icon(
                    onPressed: _playAudio,
                    icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                    label: Text(_isPlaying ? 'Stop' : 'Play'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                Semantics(
                  label: 'Save the result',
                  hint: '파일을 저장합니다.',
                  child: ElevatedButton.icon(
                    onPressed: _saveResult,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
