import 'package:get/get.dart';
import 'login_controller.dart';
import 'services/i_login_service.dart';
import 'services/login_service.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // ILoginService 인터페이스의 구현체인 LoginService를 등록합니다.
    Get.lazyPut<ILoginService>(() => LoginService());
    // LoginController는 ILoginService에 의존하므로, Get.find()를 통해 주입받습니다.
    Get.lazyPut<LoginController>(
      () => LoginController(loginService: Get.find<ILoginService>()),
    );
  }
}
