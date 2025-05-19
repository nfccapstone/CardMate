import 'package:cardmate/features/namecardbooks/card_controller.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import 'home_service.dart';
import 'services/i_home_service.dart';
import 'package:cardmate/features/more/more_service.dart';
import 'package:cardmate/features/more/more_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // IHomeService 인터페이스 구현체 등록
    Get.lazyPut<IHomeService>(() => HomeService());
    // HomeController는 IHomeService를 주입받습니다.
    Get.lazyPut<HomeController>(
      () => HomeController(homeService: Get.find<IHomeService>()),
    );
    Get.put(CardController());
    // MoreService와 MoreController 등록
    Get.lazyPut<MoreService>(() => MoreService());
    Get.lazyPut<MoreController>(() => MoreController(moreService: Get.find<MoreService>()));
  }
}
