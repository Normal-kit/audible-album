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
              hint: '두 번 탭하여 카메라를 실행하세요',
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/camera');
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(350, 350),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  backgroundColor: Colors.red[200],
                ),
                child: Text(
                  '카메라',
                  style: TextStyle(fontSize: 30.0, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 50.0),
            Semantics(
              button: true,
              label: '갤러리',
              hint: '두 번 탭하여 갤러리를 실행하세요',
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/gallery');
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(350, 350),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  backgroundColor: Colors.lightBlue,
                ),
                child: Text(
                  '갤러리',
                  style: TextStyle(fontSize: 30.0, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
