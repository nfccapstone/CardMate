import 'package:cardmate/features/home/home_binding.dart';
import 'package:cardmate/features/namecardbooks/add_card_screen.dart';
import 'package:cardmate/features/namecard/screens/block_create_screen.dart';
import 'package:cardmate/features/namecardbooks/edit_othercard_screen.dart';
import 'package:cardmate/features/register/register_binding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'firebase/firebase_init.dart';
import 'features/login/login_screen.dart';
import 'features/home/home_screen.dart';
import 'features/register/register_screen.dart';
import 'features/namecard/screens/edit_card_screen.dart';
import 'features/namecard/screens/namecard_info_screen.dart';
import 'features/namecard/screens/edit_contact_screen.dart';
import 'features/namecard/namecard_bindings.dart';
import 'features/login/login_bindings.dart';
//import 'features/register/register_binding.dart';

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
        GetPage(
          name: '/',
          page: () => const LoginScreen(),
          binding: LoginBinding()),
        GetPage(
          name: '/home', 
          page: () => const HomeScreen(),
          binding: HomeBinding()),
        GetPage(
          name: '/register', 
          page: () => const RegisterScreen(),
          binding: RegisterBinding()),
        GetPage(
          name: '/editCard', 
          page: () => const EditCardScreen(),
          binding: NameCardBindings()),
        GetPage(
          // ✅ 바인딩 포함된 단 하나의 등록만 유지
          name: '/namecardInfo',
          page: () => const NameCardInfoScreen(),
          binding: NameCardBindings(),
        ),
        GetPage(
          name: '/editContact',
          page: () => EditContactScreen(),
        ),
        GetPage(name: '/addNamecard', page: () => AddCardScreen()),
        GetPage(
          name: '/blockCreate',
          page: () => BlockCreateScreen(),
        ),
      ],
    );
  }
}
