import 'package:cardmate/features/card_id/card_id_binding.dart';
import 'package:cardmate/features/card_id/card_id_screen.dart';
import 'package:cardmate/features/home/home_binding.dart';
import 'package:cardmate/features/more/more_binding.dart';
import 'package:cardmate/features/namecard/screens/block_create_screen.dart';
import 'package:cardmate/features/namecardbooks/add_card_manual_screen.dart';
import 'package:cardmate/features/namecardbooks/edit_manual_card_screen.dart';
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
import 'features/namecard/bindings/main_namecard_bindings.dart';
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
import 'features/namecardbooks/qr_scan_screen.dart';
import 'features/more/more_screen.dart';
import 'features/namecardbooks/add_card_byNFC_screen.dart';
import 'features/namecardbooks/add_card_byId_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/namecardbooks/add_card_by_nfc_screen.dart';
import 'features/namecardbooks/add_card_by_id_screen.dart';

void main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInit.instance.initializeFirebase();

  // 자동 로그인 상태 확인
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email');
  final password = prefs.getString('password');
  final auth = FirebaseAuth.instance;

  runApp(MyApp(
    initialRoute: kIsWeb
        ? null
        : (email != null && password != null && auth.currentUser != null)
            ? '/home'
            : '/',
  ));
}

class MyApp extends StatelessWidget {
  final String? initialRoute;

  const MyApp({super.key, this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CardMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: initialRoute,
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
          page: () => const BlockCreateScreen(),
        ),
        GetPage(
          name: '/card/myNameCard/:cardId',
          page: () => const MyNameCardScreen(),
          binding: BindingsBuilder(() {
            Get.put<IEditCardService>(EditCardService());
            final cardId = Get.parameters['cardId'] ?? '';
            Get.put(MyNameCardController(
                editCardService: Get.find<IEditCardService>(), cardId: cardId));
          }),
        ),
        GetPage(
          name: '/card',
          page: () => const CardWebScreen(cardId: '11'),
        ),
        GetPage(
          name: '/qr-scan',
          page: () => const QRScanScreen(),
        ),
        GetPage(
          name: '/add-card-nfc',
          page: () => AddCardByNFCScreen(),
        ),
        GetPage(
          name: '/add-card-id',
          page: () => AddCardByIdScreen(),
        ),
        GetPage(
          name: '/add-card-manual',
          page: () => AddCardManualScreen(),
        ),
        GetPage(
          name: '/more',
          page: () => const MoreScreen(),
          binding: MoreBinding(),
        ),
        GetPage(
          name: '/edit-manual-card',
          page: () {
            final args = Get.arguments as Map<String, dynamic>?;
            final cardId = args?['cardId'] ?? '';
            return EditManualCardScreen(cardId: cardId);
          },
          binding: MainNameCardBindings(),
        ),
      ],
    );
  }
}
