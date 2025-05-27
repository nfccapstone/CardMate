import 'dart:io';
import 'package:cardmate/features/home/home_controller.dart';
import 'package:cardmate/features/namecard/controllers/edit_card_controller.dart';
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

  final isSaving = false.obs;
  final INameCardService _nameCardService;
  final IProfileImageService _profileImageService;
  Rx<File?> profileImage = Rx<File?>(null);
  RxString profileImageUrl = ''.obs;
  final ImagePicker _picker = ImagePicker();

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
      final url = data['profileImageUrl'] ?? '';
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
      String? imageUrl = profileImageUrl.value;
      if (profileImage.value != null) {
        try {
          imageUrl = await _profileImageService.uploadProfileImage(profileImage.value!);
          profileImageUrl.value = imageUrl ?? '';
        } catch (e) {
          print('프로필 이미지 업로드 에러: $e');
          rethrow;
        }
      }

      final data = {
        'name': nameController.text,
        'position': positionController.text,
        'department': departmentController.text,
        'company': companyController.text,
        'profileImageUrl': imageUrl,
      };

      try {
        await _nameCardService.saveBasicInfo(data);
      } catch (e) {
        print('기본 정보 저장 에러: $e');
        rethrow;
      }

      try {
        final editCardController = Get.find<EditCardController>();
        await editCardController.loadNameCardData();
      } catch (e) {
        print('명함 데이터 로드 에러: $e');
        rethrow;
      }

      try {
        final homeController = Get.find<HomeController>();
        await homeController.fetchCardInfo();
      } catch (e) {
        print('홈 화면 데이터 갱신 에러: $e');
        rethrow;
      }

      Get.back(result: true);
    } catch (e) {
      print('전체 저장 프로세스 에러: $e');
      Get.snackbar('오류', '저장에 실패했습니다.');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    positionController.dispose();
    departmentController.dispose();
    companyController.dispose();
    super.onClose();
  }
}
