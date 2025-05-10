import 'package:flutter/material.dart';
import 'package:myapp/CameraPage.dart';
import 'package:myapp/GalleryPage.dart';
import 'package:myapp/MainPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => MainPage(),
        '/camera': (context) => Camerapage(),
        '/gallery': (context) => Gallerypage(),
      },
    );
  }
}
