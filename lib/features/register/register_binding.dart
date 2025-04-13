import 'package:get/get.dart';
import 'register_controller.dart';
import 'services/i_register_service.dart';
import 'services/register_service.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    // IRegisterService 인터페이스의 구현체를 등록합니다.
    Get.lazyPut<IRegisterService>(() => RegisterService());
    // RegisterController는 IRegisterService에 의존하므로, 해당 서비스 구현체를 주입받습니다.
    Get.lazyPut<RegisterController>(
      () => RegisterController(registerService: Get.find<IRegisterService>()),
    );
  }
}
