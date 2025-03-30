import 'package:get/get.dart';
import 'package:cardmate/services/edit_card_service.dart';

class EditCardController extends GetxController {
  final isLoading = true.obs;
  final basicInfo = <String, dynamic>{}.obs;

  final EditCardService _service = EditCardService();

  @override
  void onInit() {
    super.onInit();
    loadNameCardData();
  }

  /// Firestore에서 명함 기본 정보 불러오기
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

  /// (추후용) 명함 정보 저장
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
}
