import 'package:get/get.dart';
import 'controllers/namecard_info_controller.dart';
import 'controllers/edit_card_controller.dart';
import 'controllers/contact_controller.dart';
import 'services/i_namecard_service.dart';
import 'services/namecard_service.dart';
import 'services/i_edit_card_service.dart';
import 'services/edit_card_service.dart';
import 'services/i_contact_service.dart';
import 'services/contact_service.dart';
import 'services/i_profile_image_service.dart';
import 'services/profile_image_service.dart';

class NameCardBindings extends Bindings {
  @override
  void dependencies() {
    // 서비스 인터페이스의 구현체 등록
    Get.lazyPut<INameCardService>(() => NameCardService());
    Get.lazyPut<IEditCardService>(() => EditCardService());
    Get.lazyPut<IContactService>(() => ContactService());
    Get.lazyPut<IProfileImageService>(() => ProfileImageService());

    // 컨트롤러에 DI로 주입 (생성자 주입)
    Get.lazyPut<NameCardInfoController>(
      () => NameCardInfoController(
        nameCardService: Get.find<INameCardService>(),
        profileImageService: Get.find<IProfileImageService>(),
      ),
    );
    Get.lazyPut<EditCardController>(
      () => EditCardController(editCardService: Get.find<IEditCardService>()),
    );

    // ContactController는 cardId가 필요하므로 여기서는 등록하지 않음
    // 대신 필요한 곳에서 직접 생성하여 사용
  }
}
