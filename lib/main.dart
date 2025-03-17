import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_init.dart'; // FirebaseInit import
import 'screens/login/login_screen.dart'; // 로그인 화면 import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInit.instance.initializeFirebase(); // ✅ Firebase 초기화 완료 후 앱 실행

  runApp(CardMateApp());
}

class CardMateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CardMate',
      theme: ThemeData(
        brightness: Brightness.dark, // 기본 다크 모드 테마
      ),
      home: LoginScreen(), // 앱 실행 시 로그인 화면으로 시작
    );
  }
}
