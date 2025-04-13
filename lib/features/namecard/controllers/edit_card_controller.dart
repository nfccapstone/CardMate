import 'package:get/get.dart';
import 'package:cardmate/features/namecard/services/i_edit_card_service.dart';

class EditCardController extends GetxController {
  final isLoading = true.obs;
  final basicInfo = <String, dynamic>{}.obs;
  final blocks = <Map<String, dynamic>>[].obs;
  final IEditCardService _service;

  // DI: IEditCardService 구현체를 생성자 주입
  EditCardController({required IEditCardService editCardService})
      : _service = editCardService;

  @override
  void onInit() {
    super.onInit();
    loadNameCardData();
  }

  Future<void> loadNameCardData() async {
    isLoading.value = true;
    final data = await _service.fetchBasicInfo();
    if (data != null) {
      basicInfo.assignAll(data);
    } else {
      Get.snackbar('오류', '명함 정보를 불러오지 못했습니다.');
    }
    isLoading.value = false;
  }

  Future<void> saveBasicInfo(Map<String, dynamic> newData) async {
    isLoading.value = true;
    final success = await _service.saveBasicInfo(newData);
    if (success) {
      basicInfo.assignAll(newData);
      Get.snackbar('저장 완료', '명함 정보가 저장되었습니다.');
    } else {
      Get.snackbar('저장 실패', '명함 정보 저장에 실패했습니다.');
    }
    isLoading.value = false;
  }

  void addBlock(String type) {
    blocks.add({'type': type, 'content': ''});
  }
}
