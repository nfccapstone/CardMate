import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cardmate/services/namecard_service.dart';

class NameCardInfoController extends GetxController {
  final nameController = TextEditingController();
  final positionController = TextEditingController();
  final departmentController = TextEditingController();
  final companyController = TextEditingController();
  final nameCardIdController = TextEditingController();

  final isSaving = false.obs;
  final NameCardService _service = NameCardService();

  Rx<File?> profileImage = Rx<File?>(null); // ✅ 선택한 이미지 파일
  RxString profileImageUrl = ''.obs;        // ✅ 저장된 이미지 URL
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadBasicInfo(); // ✅ 기본 정보 로드
  }

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      profileImage.value = File(picked.path);
    }
  }

  Future<void> loadBasicInfo() async {
  final data = await _service.fetchBasicInfo(); // Firestore에서 불러오기
  if (data != null) {
    nameController.text = data['name'] ?? '';
    positionController.text = data['position'] ?? '';
    departmentController.text = data['department'] ?? '';
    companyController.text = data['company'] ?? '';
    nameCardIdController.text = data['nameCardId'] ?? '';

    final url = data['photoUrl'] ?? '';
    if (url.isNotEmpty) {
      //profileImage.value = File(''); // 초기화용 더미
      profileImageUrl.value = url;   // ✅ 새 변수로 URL 보관
    }
  }
}

  Future<void> saveToFirebase() async {
    isSaving.value = true;

    // 기본 프로필 이미지 URL
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
      'photoUrl': photoUrl, // ✅ 사진 URL 저장
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