import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 블랙 테마 유지
      appBar: AppBar(
        title: Text("Home", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          "메인 홈 화면 (기능 추가 예정)",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
