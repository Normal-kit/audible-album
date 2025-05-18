import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotoExpandpage extends StatefulWidget {
  final File imageFile;
  final String audioFilePath;

  const PhotoExpandpage({
    super.key,
    required this.imageFile,
    required this.audioFilePath,
  });

  @override
  State<PhotoExpandpage> createState() => _PhotoExpandpageState();
}

class _PhotoExpandpageState extends State<PhotoExpandpage> {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isPlaying = false;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await _player.openPlayer();
    setState(() {
      _isPlayerReady = true;
    });

    // audioFilePath 스낵바로 보여주기
    // if (mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('오디오 파일 경로: ${widget.audioFilePath}'),
    //       duration: const Duration(seconds: 3),
    //     ),
    //   );
    // }
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (!_isPlayerReady) return;

    final file = File(widget.audioFilePath);
    if (!await file.exists()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('오디오 파일이 존재하지 않습니다.')));
      return;
    }

    if (_isPlaying) {
      await _player.stopPlayer();
      setState(() {
        _isPlaying = false;
      });
    } else {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('마이크 권한이 필요합니다.')));
        return;
      }

      await _player.startPlayer(
        fromURI: widget.audioFilePath,
        codec: Codec.aacADTS, // 필요에 따라 변경
        whenFinished: () {
          setState(() {
            _isPlaying = false;
          });
        },
      );
      setState(() {
        _isPlaying = true;
      });
    }
  }

  Future<void> _deleteImageAndData() async {
    try {
      final imagePath = widget.imageFile.path;
      final audioPath = widget.audioFilePath;

      // 이미지 및 오디오 파일 삭제
      final imageFile = File(imagePath);
      final audioFile = File(audioPath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
      if (await audioFile.exists()) {
        await audioFile.delete();
      }

      // JSON 파일 삭제
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();
      for (final file in files.whereType<File>()) {
        if (file.path.endsWith('.json')) {
          final content = await file.readAsString();
          final decoded = jsonDecode(content);
          if (decoded['imagePath'] == imagePath) {
            await file.delete();
            break;
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('삭제 중 오류 발생: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 뒤로 가기 버튼
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Semantics(
                    label: '뒤로가기',
                    excludeSemantics: true,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                  const Spacer(),
                  Semantics(
                    button: true,
                    excludeSemantics: true,
                    label: '사진삭제',
                    child: ElevatedButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              contentPadding: const EdgeInsets.all(
                                24,
                              ), // 여백 넉넉하게
                              content: SizedBox(
                                width:
                                    MediaQuery.of(context).size.width *
                                    0.9, // 전체 너비의 90%
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Semantics(
                                      label: '정말 삭제하시겠습니까?',
                                      excludeSemantics: true,
                                      child: Text(
                                        '삭제하시겠어요?',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Semantics(
                                          button: true,
                                          excludeSemantics: true,
                                          label: '삭제 취소 버튼입니다',
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey,
                                              minimumSize: const Size(120, 55),
                                            ),
                                            onPressed:
                                                () =>
                                                    Navigator.of(context).pop(),
                                            child: const Text(
                                              '취소',
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ),
                                        ),
                                        Semantics(
                                          button: true,
                                          excludeSemantics: true,
                                          label:
                                              '삭제 확인 버튼입니다. 사진과 관련된 모든 정보가 삭제됩니다.',
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              minimumSize: const Size(120, 55),
                                            ),
                                            onPressed: () async {
                                              await _deleteImageAndData();
                                              if (mounted) {
                                                Navigator.of(context).pop();
                                                Future.delayed(
                                                  Duration(milliseconds: 100),
                                                  () {
                                                    if (mounted) {
                                                      Navigator.of(
                                                        context,
                                                      ).pop(true);
                                                    }
                                                  },
                                                );
                                              }
                                            },
                                            child: const Text(
                                              '삭제',
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(150, 0),
                        backgroundColor: Colors.blueGrey,
                      ),
                      child: Text('삭제', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            // 이미지 표시
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    widget.imageFile,
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 오디오 재생 버튼
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: ElevatedButton(
                onPressed: _togglePlayback,
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(300, 70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  backgroundColor: _isPlaying ? Colors.red : Colors.blueGrey,
                ),
                child: Text(
                  _isPlaying ? '재생 중지' : '음성 재생',
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
