import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class Gallerypage extends StatefulWidget {
  const Gallerypage({super.key});

  @override
  State<Gallerypage> createState() => _GallerypageState();
}

class _GallerypageState extends State<Gallerypage> {
  List<File> _imageFiles = [];

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            //뒤로가기 + 년/월 버튼
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

            //저장된 이미지들을 2열 그리드로 보여주기
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
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_imageFiles[index], fit: BoxFit.cover),
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
