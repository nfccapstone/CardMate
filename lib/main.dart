import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'services/firebase/firebase_init.dart';
import 'screens/login/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/nfc_write_screen.dart';
import 'screens/home/nfc_read_screen.dart';
import 'screens/register/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInit.instance.initializeFirebase(); // ✅ Firebase 초기화 완료 후 앱 실행

  runApp(const CardMateApp());
}

class CardMateApp extends StatelessWidget {
  const CardMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // ✅ GetX 적용
      debugShowCheckedModeBanner: false,
      title: 'CardMate',
      theme: ThemeData(
        brightness: Brightness.dark, // 기본 다크 모드 테마
      ),
      initialRoute: '/', // 기본 시작 화면 (로그인 화면)
      getPages: [
        GetPage(name: '/', page: () => const LoginScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(name: '/nfcWrite', page: () => const NfcWriteScreen()),
        GetPage(name: '/nfcRead', page: () => const NfcReadScreen()),
      ],
    );
  }
}
