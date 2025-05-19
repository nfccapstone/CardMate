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
import 'features/namecard/main_namecard_bindings.dart';
import 'features/login/login_bindings.dart';
import 'features/namecard/services/namecard_service.dart';
import 'features/namecard/services/i_namecard_service.dart';
import 'features/namecard/screens/my_namecard_screen.dart';
import 'features/namecard/controllers/my_namecard_controller.dart';
import 'features/namecard/services/edit_card_service.dart';
import 'features/namecard/services/i_edit_card_service.dart';
import 'features/namecard/screens/card_web_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:url_strategy/url_strategy.dart';
import 'features/namecard/bindings/contact_bindings.dart';

void main() async {
  setPathUrlStrategy(); // 웹에서 # 없는 URL 사용
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
      initialRoute: kIsWeb ? null : '/', // 웹은 URL 해석, 앱은 로그인화면
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
            binding: MainNameCardBindings()),
        GetPage(
          name: '/namecardInfo',
          page: () => const NameCardInfoScreen(),
          binding: MainNameCardBindings(),
        ),
        GetPage(
          name: '/editContact',
          page: () => EditContactScreen(),
          binding: ContactBindings(),
        ),
        GetPage(
          name: '/blockCreate',
          page: () => BlockCreateScreen(),
        ),
        GetPage(
          name: '/card/myNameCard/:cardId',
          page: () => MyNameCardScreen(),
          binding: BindingsBuilder(() {
            Get.put<IEditCardService>(EditCardService());
            final cardId = Get.parameters['cardId'] ?? '';
            Get.put(MyNameCardController(
                editCardService: Get.find<IEditCardService>(),
                cardId: cardId));
          }),
        ),
        GetPage(
          name: '/card',
          page: () => const CardWebScreen(cardId: '11'),
        ),
      ],
    );
  }
}
