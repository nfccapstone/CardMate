import 'package:get/get.dart';
import 'package:cardmate/getX/controllers/namecard_info_controller.dart';

class NameCardBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NameCardInfoController>(() => NameCardInfoController());
  }
}
