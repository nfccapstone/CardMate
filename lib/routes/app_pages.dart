import 'package:cardmate/features/namecardbooks/add_manual_card_screen.dart';
import 'package:cardmate/features/namecardbooks/edit_manual_card_screen.dart';
import 'package:cardmate/features/namecardbooks/manual_card_detail_screen.dart';
import 'package:get/get.dart';

class AppPages {
  static final routes = [
    // ... existing routes ...
    GetPage(
      name: '/add-manual-card',
      page: () => const AddManualCardScreen(),
    ),
    GetPage(
      name: '/manual-card-detail',
      page: () => ManualCardDetailScreen(
        cardId: Get.arguments['cardId'],
        cardData: Get.arguments['cardData'],
      ),
    ),
    GetPage(
      name: '/edit-manual-card',
      page: () => EditManualCardScreen(
        cardId: Get.arguments['cardId'],
        cardData: Get.arguments['cardData'],
      ),
    ),
  ];
} 