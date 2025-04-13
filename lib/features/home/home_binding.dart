import 'package:get/get.dart';
import 'home_controller.dart';
import 'home_service.dart';
import 'services/i_home_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // IHomeService 인터페이스 구현체 등록
    Get.lazyPut<IHomeService>(() => HomeService());
    // HomeController는 IHomeService를 주입받습니다.
    Get.lazyPut<HomeController>(
      () => HomeController(homeService: Get.find<IHomeService>()),
    );
  }
}
