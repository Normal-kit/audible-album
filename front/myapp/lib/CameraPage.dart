import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class Camerapage extends StatefulWidget {
  const Camerapage({super.key});

  @override
  State<Camerapage> createState() => _CamerapageState();
}

class _CamerapageState extends State<Camerapage> {
  File? _imageFile;
  String _gptResult = '\u200B';

  @override
  void initState() {
    super.initState();
    _pickImageFromCamera();
  }

  Future<void> _pickImageFromCamera() async {
    setState(() {
      _gptResult = '\u200B';
    });

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final tempImage = File(pickedFile.path);
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = p.basename(pickedFile.path);
      final savedImage = await tempImage.copy('${appDir.path}/$fileName');

      setState(() {
        _imageFile = savedImage;
      });

      await _analyzeImageWithGPT(savedImage);
    }
    if (pickedFile == null) {
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: null,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                liveRegion: true,
                container: true,
                child: Text(message, style: TextStyle(fontSize: 16)),
              ),

              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    button: true,
                    label: "재시도합니다",
                    excludeSemantics: true,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(120, 48),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (_imageFile != null) {
                          _analyzeImageWithGPT(_imageFile!);
                        }
                      },
                      child: Text('재시도'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Semantics(
                    button: true,
                    label: '메인화면으로 이동합니다',
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(120, 48),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text('메인화면으로'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _analyzeImageWithGPT(File image) async {
    final uri = Uri.parse('http://223.130.160.126:8000/upload/photo');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('photo', image.path));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        final description = data['data']?['description'];

        setState(() {
          _gptResult = description;
          if (description == null) {
            _showErrorDialog('분석에 실패했습니다. 다시 시도하시겠습니까?');
          }
        });
      } else {
        setState(() {});
        _showErrorDialog('서버 오류가 발생했습니다. 다시 시도하시겠습니까?');
      }
    } catch (e) {
      setState(() {
        if (e.toString() == 'Connection failed') {
          _showErrorDialog('네트워크에 연결되지 않았습니다. 다시 시도하시겠습니까?');
        } else {
          _showErrorDialog('분석에 실패했습니다. 다시 시도하시겠습니까?');
        }
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
                  const SizedBox(height: 100.0),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Semantics(
                          liveRegion: true,
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
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 24,
                        top: 10,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Semantics(
                                button: true,
                                label: '녹음',
                                hint: '녹음화면으로 넘어갑니다',
                                excludeSemantics: true,
                                child: IconButton(
                                  icon: Image.asset(
                                    'assets/images/mic.png',
                                    width: 100,
                                    height: 100,
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/record',
                                      arguments: {
                                        'imagePath': _imageFile!.path,
                                        'gptResult': _gptResult,
                                      },
                                    );
                                  },
                                ),
                              ),
                              Semantics(
                                button: true,
                                label: '재촬영',
                                excludeSemantics: true,
                                child: IconButton(
                                  icon: Image.asset(
                                    'assets/images/repeat_camera.png',
                                    width: 100,
                                    height: 100,
                                  ),
                                  onPressed: _pickImageFromCamera,
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
              : const Center(child: Text('로딩중...')),
    );
  }
}
