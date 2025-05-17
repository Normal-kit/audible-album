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
  List<File> _imageFiles = [];
  Map<String, String> _imageDescriptions = {}; // 이미지 경로 -> 설명

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
    _loadDescriptions();
  }

  Future<void> _loadSavedImages() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync();

    final imageFiles =
        files.whereType<File>().where((file) {
          final ext = extension(file.path).toLowerCase();
          return ext == '.jpg' || ext == '.jpeg' || ext == '.png';
        }).toList();

    setState(() {
      _imageFiles = imageFiles;
    });
  }

  Future<void> _loadDescriptions() async {
    try {
      final dir = await getApplicationDocumentsDirectory();

      // app_flutter 폴더 내 모든 json 파일을 읽어 리스트에 추가
      final files = dir.listSync();

      Map<String, String> descriptions = {};

      for (final file in files.whereType<File>()) {
        if (extension(file.path).toLowerCase() == '.json') {
          final content = await file.readAsString();
          final decoded = jsonDecode(content);
          final imagePath = decoded['imagePath'];
          final gptResult = decoded['gptResult'];
          if (imagePath != null && gptResult != null) {
            descriptions[imagePath] = gptResult;
          }
        }
      }

      setState(() {
        _imageDescriptions = descriptions;
      });
    } catch (e) {
      print('설명 로딩 실패: $e');
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
                  itemCount: _imageFiles.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final file = _imageFiles[index];
                    final description =
                        _imageDescriptions[file.path] ?? '이미지 설명이 없습니다';

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PhotoExpandpage(imageFile: file),
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
