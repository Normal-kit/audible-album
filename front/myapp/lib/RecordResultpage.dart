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
      appBar: AppBar(title: const Text('결과화면')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: '재녹음',
              hint: '녹음화면으로 돌아갑니다',
              button: true,
              excludeSemantics: true,
              child: IconButton(
                icon: Image.asset(
                  'assets/images/mic.png',
                  width: 150,
                  height: 150,
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/record',
                    arguments: {'imagePath': imagePath, 'gptResult': gptResult},
                  );
                },
                padding: EdgeInsets.all(50.0),
              ),
            ),
            Semantics(
              label: _isPlaying ? '중지' : '재생',
              hint: _isPlaying ? '중지합니다.' : '재생합니다.',
              button: true,
              excludeSemantics: true,
              child: IconButton(
                icon: Image.asset(
                  'assets/images/play_stop.png',
                  width: 130,
                  height: 130,
                ),
                onPressed: _playAudio,
                padding: EdgeInsets.all(50.0),
              ),
            ),
            Semantics(
              label: '저장',
              hint: '파일을 저장하고 메인화면으로 돌아갑니다',
              button: true,
              excludeSemantics: true,
              child: IconButton(
                icon: Image.asset(
                  'assets/images/save.png',
                  width: 150,
                  height: 150,
                ),
                onPressed: _saveResult,
                padding: EdgeInsets.all(50.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
