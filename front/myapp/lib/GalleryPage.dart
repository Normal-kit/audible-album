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
  List<String> _filteredImagePaths = []; // 필터링된 이미지 리스트

  Map<String, String> _imageDescriptions = {};
  Map<String, String> _imageAudioPaths = {};
  Map<String, String> _imageTimestamps = {};

  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();

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

          if (imagePath != null && await File(imagePath).exists()) {
            imagePaths.add(imagePath);
            if (gptResult != null) descriptions[imagePath] = gptResult;
            if (audioPath != null) audioPaths[imagePath] = audioPath;
            if (timestamp != null) timestamps[imagePath] = timestamp;
          }
        }
      }

      setState(() {
        _imagePaths = imagePaths;
        _filteredImagePaths = imagePaths; // 초기에는 전체 이미지 표시
        _imageDescriptions = descriptions;
        _imageAudioPaths = audioPaths;
        _imageTimestamps = timestamps;
      });
    } catch (e) {
      print('설명 및 이미지 로딩 실패: $e');
    }
  }

  void _applyFilter() {
    final year = _yearController.text.trim();
    final month = _monthController.text.trim().padLeft(2, '0');

    if (year.isEmpty || month.isEmpty) {
      setState(() {
        _filteredImagePaths = _imagePaths;
      });
      return;
    }

    final filterKey = '$year-$month';

    setState(() {
      _filteredImagePaths = _imagePaths.where((path) {
        final timestamp = _imageTimestamps[path];
        return timestamp != null && timestamp.startsWith(filterKey);
      }).toList();
    });
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '년',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _monthController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '월',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _applyFilter,
                    child: const Text('검색'),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  itemCount: _filteredImagePaths.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final imagePath = _filteredImagePaths[index];
                    final file = File(imagePath);

                    final description = _imageDescriptions[imagePath] ?? '이미지 설명이 없습니다';
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
