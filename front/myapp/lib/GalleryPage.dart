import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:myapp/PhotoExpandpage.dart';

class Gallerypage extends StatefulWidget {
  const Gallerypage({super.key});

  @override
  State<Gallerypage> createState() => _GallerypageState();
}

class _GallerypageState extends State<Gallerypage> {
  List<String> _imagePaths = [];

  // 이미지 경로를 키로 하여 각각 값을 저장하는 Map들
  Map<String, String> _imageDescriptions = {}; // imagePath -> GPT 결과
  Map<String, String> _imageAudioPaths = {};   // imagePath -> audioPath
  Map<String, String> _imageTimestamps = {};   // imagePath -> 녹음 시간

  @override
  void initState() {
    super.initState();
    _loadDescriptionsAndImages();
  }

  Future<void> _loadDescriptionsAndImages() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = dir.listSync();

      Map<String, String> descriptions = {};
      Map<String, String> audioPaths = {};
      Map<String, String> timestamps = {};
      List<String> imagePaths = [];

      for (final file in files.whereType<File>()) {
        if (extension(file.path).toLowerCase() == '.json') {
          final content = await file.readAsString();
          final decoded = jsonDecode(content);

          final imagePath = decoded['imagePath'] as String?;
          final gptResult = decoded['gptResult'] as String?;
          final audioPath = decoded['audioPath'] as String?;
          final timestamp = decoded['timestamp'] as String?;

          if (imagePath != null) {
            // 이미지 파일이 실제로 존재하는지 체크
            if (await File(imagePath).exists()) {
              imagePaths.add(imagePath);

              if (gptResult != null) {
                descriptions[imagePath] = gptResult;
              }
              if (audioPath != null) {
                audioPaths[imagePath] = audioPath;
              }
              if (timestamp != null) {
                timestamps[imagePath] = timestamp;
              }
            }
          }
        }
      }

      setState(() {
        _imagePaths = imagePaths;
        _imageDescriptions = descriptions;
        _imageAudioPaths = audioPaths;
        _imageTimestamps = timestamps;
      });
    } catch (e) {
      print('설명 및 이미지 로딩 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 버튼들
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  ElevatedButton(onPressed: () {}, child: const Text('년')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: () {}, child: const Text('월')),
                ],
              ),
            ),

            // 이미지 그리드
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  itemCount: _imagePaths.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final imagePath = _imagePaths[index];
                    final file = File(imagePath);

                    final description =
                        _imageDescriptions[imagePath] ?? '이미지 설명이 없습니다';

                    final audioPath = _imageAudioPaths[imagePath] ??
                        imagePath.replaceAll(RegExp(r'\.(jpg|jpeg|png)$'), '.aac');

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PhotoExpandpage(
                              imageFile: file,
                              audioFilePath: audioPath,
                            ),
                          ),
                        );
                      },
                      child: Semantics(
                        label: description,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(file, fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
