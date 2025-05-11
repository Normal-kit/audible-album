import 'package:flutter/material.dart';

class Recordpage extends StatelessWidget {
  const Recordpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              button: true,
              label: '녹음하기',
              hint: '버튼을 두번클릭하면 녹음이 시작되고 다시 두번클릭하면 녹음이 중지됩니다.',
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/recordresult');
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(350, 350),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  backgroundColor: Colors.lightBlue,
                ),
                child: Text(
                  '녹음',
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
