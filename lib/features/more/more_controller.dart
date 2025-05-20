import 'package:get/get.dart';
import 'more_service.dart';

class MoreController extends GetxController {
  final MoreService _moreService;

  MoreController({required MoreService moreService}) : _moreService = moreService;

  Future<void> logout() async {
    await _moreService.logout();
    Get.offAllNamed('/login');
  }
} 