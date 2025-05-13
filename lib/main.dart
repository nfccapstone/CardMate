import 'package:cardmate/features/card_id/card_id_binding.dart';
import 'package:cardmate/features/card_id/card_id_screen.dart';
import 'package:cardmate/features/home/home_binding.dart';
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
import 'features/namecard/services/namecard_service.dart';
import 'features/namecard/services/i_namecard_service.dart';
import 'features/namecard/screens/my_namecard_screen.dart';
import 'features/namecard/controllers/my_namecard_controller.dart';
import 'features/namecard/services/edit_card_service.dart';
import 'features/namecard/services/i_edit_card_service.dart';
//import 'features/register/register_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInit.instance.initializeFirebase(); // ✅ Firebase 초기화 완료 후 앱 실행

  // INameCardService를 GetX에 등록
  Get.put<INameCardService>(NameCardService());

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
            name: '/cardId',
            page: () => const CardIdScreen(),
            binding: CardIdBinding()),
        GetPage(
            name: '/editCard',
            page: () {
              final args = Get.arguments as Map<String, dynamic>?;
              final cardId = args?['cardId'] ?? '';
              return EditCardScreen(cardId: cardId);
            },
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
        //GetPage(name: '/addNamecard', page: () => AddCardScreen()),
        GetPage(
          name: '/blockCreate',
          page: () => BlockCreateScreen(),
        ),
        GetPage(
          name: '/myNameCard',
          page: () => const MyNameCardScreen(),
          binding: BindingsBuilder(() {
            Get.put<IEditCardService>(EditCardService());
            Get.put(MyNameCardController(
                editCardService: Get.find<IEditCardService>()));
          }),
        ),
      ],
    );
  }
}
