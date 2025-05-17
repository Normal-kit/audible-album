import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

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
    final appDir = directory.path;

    final uuid = const Uuid().v4();

    final result = {
      'imagePath': imagePath,
      'gptResult': gptResult,
      'audioPath': audioPath,
      'timestamp': timestamp,
    };

    final resultFile = File('$appDir/$uuid.json');
    await resultFile.writeAsString(jsonEncode(result));
/*
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('파일 저장 위치: ${resultFile.path}'),
        duration: const Duration(seconds: 4),
      ),
    );
*/
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;

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
              Text(
                '이미지 분석 결과: $gptResult',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 16),
            if (timestamp != null)
              Text('녹음 시간: $timestamp', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Semantics(
                  label: '재녹음',
                  hint: '녹음화면으로 돌아갑니다',
                  button: true,
                  excludeSemantics: true,
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
                    label: const Text('재녹음'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ),
                Semantics(
                  label: _isPlaying ? '재생 중지' : '재생',
                  hint: _isPlaying ? '재생을 중지합니다.' : '재생합니다.',
                  button: true,
                  excludeSemantics: true,
                  child: ElevatedButton.icon(
                    onPressed: _playAudio,
                    icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                    label: Text(_isPlaying ? '중지' : '재생'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                Semantics(
                  label: '저장',
                  hint: '파일을 저장합니다.',
                  button: true,
                  excludeSemantics: true,
                  child: ElevatedButton.icon(
                    onPressed: _saveResult,
                    icon: const Icon(Icons.save),
                    label: const Text('저장'),
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
