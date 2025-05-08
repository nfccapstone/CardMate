import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cardmate/features/namecard/services/i_namecard_service.dart';
import 'package:cardmate/features/namecard/services/i_profile_image_service.dart';

class NameCardInfoController extends GetxController {
  final nameController = TextEditingController();
  final positionController = TextEditingController();
  final departmentController = TextEditingController();
  final companyController = TextEditingController();
  final nameCardIdController = TextEditingController();

  final isSaving = false.obs;
  final INameCardService _nameCardService;
  final IProfileImageService _profileImageService;
  Rx<File?> profileImage = Rx<File?>(null);
  RxString profileImageUrl = ''.obs;
  RxString nameCardId = ''.obs;
  final ImagePicker _picker = ImagePicker();

  // 의존성 주입: INameCardService와 IProfileImageService 구현체를 전달 받습니다.
  NameCardInfoController({
    required INameCardService nameCardService,
    required IProfileImageService profileImageService,
  })  : _nameCardService = nameCardService,
        _profileImageService = profileImageService;

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
    final data = await _nameCardService.fetchBasicInfo();
    if (data != null) {
      nameController.text = data['name'] ?? '';
      positionController.text = data['position'] ?? '';
      departmentController.text = data['department'] ?? '';
      companyController.text = data['company'] ?? '';
      nameCardIdController.text = data['nameCardId'] ?? '';
      nameCardId.value = data['nameCardId'] ?? '';
      final url = data['photoUrl'] ?? '';
      if (url.isNotEmpty) {
        profileImageUrl.value = url;
      }
    }
  }

  Future<void> saveToFirebase() async {
    if (nameController.text.isEmpty) {
      Get.snackbar('오류', '이름을 입력해주세요.');
      return;
    }

    isSaving.value = true;
    try {
      String? photoUrl = profileImageUrl.value;
      if (profileImage.value != null) {
        photoUrl = await _profileImageService.uploadProfileImage(profileImage.value!);
      }

      final data = {
        'name': nameController.text,
        'position': positionController.text,
        'department': departmentController.text,
        'company': companyController.text,
        'nameCardId': nameCardIdController.text,
        'photoUrl': photoUrl,
      };

      await _nameCardService.saveBasicInfo(data);
      Get.back(result: true);
    } catch (e) {
      Get.snackbar('오류', '저장에 실패했습니다.');
    } finally {
      isSaving.value = false;
    }
  }

  String getCardLink() {
    if (nameCardId.value.isEmpty) {
      return 'cardmate.link';
    }
    return 'cardmate.link/@${nameCardId.value}';
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
