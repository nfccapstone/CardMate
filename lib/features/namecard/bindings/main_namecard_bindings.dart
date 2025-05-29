import 'package:get/get.dart';
import 'package:cardmate/features/namecard/controllers/namecard_info_controller.dart';
import 'package:cardmate/features/namecard/controllers/edit_card_controller.dart';
import 'package:cardmate/features/namecard/services/i_namecard_service.dart';
import 'package:cardmate/features/namecard/services/namecard_service.dart';
import 'package:cardmate/features/namecard/services/i_edit_card_service.dart';
import 'package:cardmate/features/namecard/services/edit_card_service.dart';
import 'package:cardmate/features/namecard/services/i_profile_image_service.dart';
import 'package:cardmate/features/namecard/services/profile_image_service.dart';
import 'package:cardmate/features/namecard/services/i_contact_service.dart';
import 'package:cardmate/features/namecard/services/contact_service.dart';

class MainNameCardBindings extends Bindings {
  @override
  void dependencies() {
    // 서비스 인터페이스의 구현체 등록
    Get.lazyPut<INameCardService>(() => NameCardService());
    Get.lazyPut<IEditCardService>(() => EditCardService());
    Get.lazyPut<IProfileImageService>(() => ProfileImageService());
    Get.lazyPut<IContactService>(() => ContactService());

    // 컨트롤러에 DI로 주입 (생성자 주입)
    Get.lazyPut<NameCardInfoController>(
      () => NameCardInfoController(
        nameCardService: Get.find<INameCardService>(),
        profileImageService: Get.find<IProfileImageService>(),
      ),
    );
    Get.put<EditCardController>(
      EditCardController(editCardService: Get.find<IEditCardService>()),
    );
  }
} 