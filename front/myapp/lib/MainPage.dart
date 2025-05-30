import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              button: true,
              label: '카메라',
              hint: '카메라를 실행합니다',
              excludeSemantics: true,
              child: IconButton(
                icon: Image.asset(
                  'assets/images/camera.png',
                  width: 330,
                  height: 330,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/camera');
                },
              ),
            ),
            SizedBox(height: 50.0),
            Semantics(
              button: true,
              excludeSemantics: true,
              label: '갤러리',
              hint: '갤러리를 실행합니다',
              child: IconButton(
                icon: Image.asset(
                  'assets/images/gallery.png',
                  width: 350,
                  height: 350,
                ),
                iconSize: 0.5,
                onPressed: () {
                  Navigator.pushNamed(context, '/gallery');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
