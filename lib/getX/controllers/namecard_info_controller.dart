import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/services/namecard_service.dart';

class NameCardInfoController extends GetxController {
  final nameController = TextEditingController();
  final positionController = TextEditingController();
  final departmentController = TextEditingController();
  final companyController = TextEditingController();
  final nameCardIdController = TextEditingController();

  final isSaving = false.obs;
  final NameCardService _service = NameCardService();

  Future<void> saveToFirebase() async {
    isSaving.value = true;

    final data = {
      'name': nameController.text.trim(),
      'position': positionController.text.trim(),
      'department': departmentController.text.trim(),
      'company': companyController.text.trim(),
      'nameCardId': nameCardIdController.text.trim(),
    };

    final success = await _service.saveBasicInfo(data);
    if (success) {
      Get.snackbar('저장 완료', '기본 정보가 저장되었습니다.');
      }
  }


  @override
  void onClose() {
    nameController.dispose();
    positionController.dispose();
    departmentController.dispose();
    companyController.dispose();
    nameCardIdController.dispose();
    super.onClose();
  }
}
