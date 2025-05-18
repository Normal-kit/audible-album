import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class Recordpage extends StatefulWidget {
  const Recordpage({super.key});

  @override
  _RecordpageState createState() => _RecordpageState();
}

class _RecordpageState extends State<Recordpage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _filePath;
  Map? _args;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw RecordingPermissionException("마이크 권한이 필요합니다.");
    }
  }

  Future<void> _startRecording() async {
    try {
      if (_recorder.isRecording) {
        print('이미 녹음 중입니다.');
        return;
      }

      final status = await Permission.microphone.status;
      if (!status.isGranted) {
        final reqStatus = await Permission.microphone.request();
        if (!reqStatus.isGranted) {
          throw RecordingPermissionException("마이크 권한이 필요합니다.");
        }
      }

      final directory = await getApplicationDocumentsDirectory();
      final uuid = const Uuid().v4();
      _filePath = '${directory.path}/$uuid.aac';

      await _recorder.startRecorder(toFile: _filePath, codec: Codec.aacADTS);

      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('녹음 시작 중 오류: $e');
      setState(() {
        _isRecording = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('녹음 시작에 실패했습니다: $e')));
    }
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });

    final timestamp = DateTime.now().toString();

    Navigator.pushNamed(
      context,
      '/recordresult',
      arguments: {
        'imagePath': _args?['imagePath'],
        'gptResult': _args?['gptResult'],
        'audioPath': _filePath,
        'timestamp': timestamp,
      },
    );
  }

  void _toggleRecording() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _args = ModalRoute.of(context)?.settings.arguments as Map?;
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Semantics(
          label: '녹음 시작버튼',
          hint: '한번탭하면 녹음을 시작하고 다시한번더 탭하면 녹음을 마칩니다.',
          child: ElevatedButton(
            onPressed: _toggleRecording,
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(350, 350),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
              backgroundColor: _isRecording ? Colors.red : Colors.lightBlue,
            ),
            child: Text(
              _isRecording ? '녹음 중지' : '녹음 시작',
              style: const TextStyle(fontSize: 30.0, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
