import 'package:get/get.dart';
import 'package:cardmate/features/namecard/controllers/contact_controller.dart';
import 'package:cardmate/features/namecard/services/contact_service.dart';
import 'package:cardmate/features/namecard/services/i_contact_service.dart';

class NameCardBindings extends Bindings {
  @override
  void dependencies() {
    // ContactService를 싱글톤으로 등록
    Get.lazyPut<IContactService>(() => ContactService(), fenix: true);
    
    // ContactController를 싱글톤으로 등록
    Get.lazyPut<ContactController>(
      () => ContactController(contactService: Get.find<IContactService>()),
      fenix: true,
    );
  }
} 