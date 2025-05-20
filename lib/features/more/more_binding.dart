import 'package:get/get.dart';
import 'more_controller.dart';
import 'more_service.dart';

class MoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MoreService>(() => MoreService());
    Get.lazyPut<MoreController>(
      () => MoreController(moreService: Get.find<MoreService>()),
    );
  }
} 