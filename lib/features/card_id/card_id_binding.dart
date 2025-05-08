import 'package:get/get.dart';
import 'card_id_controller.dart';
import 'i_card_id_service.dart';
import 'card_id_service.dart';

class CardIdBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ICardIdService>(() => CardIdService());
    Get.lazyPut<CardIdController>(
      () => CardIdController(
        cardIdService: Get.find<ICardIdService>(),
        userId: Get.arguments['userId'] ?? '',
      ),
    );
  }
}
