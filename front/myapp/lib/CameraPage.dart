import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart'; // for basename()
import 'dart:io';

class Camerapage extends StatefulWidget {
  const Camerapage({super.key});

  @override
  State<Camerapage> createState() => _CamerapageState();
}

class _CamerapageState extends State<Camerapage> {
  File? _imageFile;
  String _gptResult = '이미지를 분석 중입니다...';

  @override
  void initState() {
    super.initState();
    _pickImageFromCamera();
  }

  Future<void> _pickImageFromCamera() async {
    setState(() {
      _gptResult = '이미지를 분석 중입니다...'; // 분석 시작 전 메시지 초기화
    });

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final tempImage = File(pickedFile.path);

      //앱 전용 디렉토리에 저장
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = basename(pickedFile.path);
      final savedImage = await tempImage.copy('${appDir.path}/$fileName');
      print('이미지 저장 경로: ${savedImage.path}');
      setState(() {
        _imageFile = savedImage;
      });

      await _analyzeImageWithGPT(savedImage);
    } else {}
  }

  Future<void> _analyzeImageWithGPT(File image) async {
    setState(() {
      _gptResult = '이미지를 분석 중입니다...';
    });

    final uri = Uri.parse(
      'http://223.130.160.126:8000/upload/photo',
    ); // FastAPI 서버 주소

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('photo', image.path));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        final description = data['data']?['description'];

        setState(() {
          _gptResult = description ?? '설명을 가져올 수 없습니다.';
        });
      } else {
        setState(() {
          _gptResult = '분석 실패: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _gptResult = '에러 발생: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _imageFile != null
              ? Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        margin: const EdgeInsets.only(top: 100),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _imageFile!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 100.0),

                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 150,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.topLeft,
                          child: Text(
                            _gptResult,
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 4,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 24,
                        top: 12,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/record');
                                },
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(100, 100),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text(
                                  '녹음',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              ElevatedButton(
                                onPressed: () {
                                  _pickImageFromCamera();
                                },
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(100, 100),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  backgroundColor: Colors.blue,
                                ),
                                child: const Text(
                                  '재촬영',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
              : const Center(child: Text('이미지를 불러오는 중...')),
    );
  }
}
