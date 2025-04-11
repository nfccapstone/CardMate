import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cardmate/features/namecard/services/i_namecard_service.dart';

class NameCardInfoController extends GetxController {
  final nameController = TextEditingController();
  final positionController = TextEditingController();
  final departmentController = TextEditingController();
  final companyController = TextEditingController();
  final nameCardIdController = TextEditingController();

  final isSaving = false.obs;
  final INameCardService _service;
  Rx<File?> profileImage = Rx<File?>(null);
  RxString profileImageUrl = ''.obs;
  final ImagePicker _picker = ImagePicker();

  // 의존성 주입: INameCardService 구현체를 전달 받습니다.
  NameCardInfoController({required INameCardService nameCardService})
      : _service = nameCardService;

  @override
  void onInit() {
    super.onInit();
    loadBasicInfo();
  }

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      profileImage.value = File(picked.path);
    }
  }

  Future<void> loadBasicInfo() async {
    final data = await _service.fetchBasicInfo();
    if (data != null) {
      nameController.text = data['name'] ?? '';
      positionController.text = data['position'] ?? '';
      departmentController.text = data['department'] ?? '';
      companyController.text = data['company'] ?? '';
      nameCardIdController.text = data['nameCardId'] ?? '';
      final url = data['photoUrl'] ?? '';
      if (url.isNotEmpty) {
        profileImageUrl.value = url;
      }
    }
  }

  Future<void> saveToFirebase() async {
    isSaving.value = true;
    String photoUrl = 'https://default-profile-image.com/default.jpg';
    if (profileImage.value != null) {
      photoUrl = await _service.uploadProfileImage(profileImage.value!);
    } else if (profileImageUrl.isNotEmpty) {
      photoUrl = profileImageUrl.value;
    }
    final data = {
      'name': nameController.text.trim(),
      'position': positionController.text.trim(),
      'department': departmentController.text.trim(),
      'company': companyController.text.trim(),
      'nameCardId': nameCardIdController.text.trim(),
      'photoUrl': photoUrl,
    };
    final success = await _service.saveBasicInfo(data);
    if (success) {
      Get.snackbar('저장 완료', '기본 정보가 저장되었습니다.');
    }
    isSaving.value = false;
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
