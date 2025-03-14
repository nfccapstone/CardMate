import 'package:flutter/material.dart';
import 'login.dart'; // 로그인 화면 불러오기

void main() {
  runApp(CardMateApp());
}

class CardMateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
      title: 'CardMate',
      theme: ThemeData(
        brightness: Brightness.dark, // 기본 다크 모드 테마
      ),
      home: LoginScreen(), // 앱 실행 시 로그인 화면으로 시작
    );
  }
}
