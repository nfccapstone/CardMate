import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'services/i_register_service.dart';

class RegisterController extends GetxController {
  // RegisterService 구체 클래스 대신 IRegisterService 인터페이스에 의존합니다.
  final IRegisterService _registerService;

  // 생성자 주입: DI를 통해 구현체를 전달받습니다.
  RegisterController({required IRegisterService registerService})
      : _registerService = registerService;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final positionController = TextEditingController();
  final companyController = TextEditingController();

  Future<void> register() async {
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        "회원가입 실패",
        "비밀번호가 일치하지 않습니다.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      return;
    }

    try {
      var user = await _registerService.signUp(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        phone: phoneController.text.trim(),
        position: positionController.text.trim().isEmpty
            ? null
            : positionController.text.trim(),
        company: companyController.text.trim().isEmpty
            ? null
            : companyController.text.trim(),
      );

      if (user != null) {
        Get.snackbar(
          "회원가입 성공",
          "로그인 화면으로 이동합니다.",
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.back(); // 로그인 화면으로 이동
      } else {
        Get.snackbar(
          "회원가입 실패",
          "다시 시도하세요.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Get.snackbar(
        "오류",
        "회원가입 중 예기치 못한 오류가 발생했습니다.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    positionController.dispose();
    companyController.dispose();
    super.onClose();
  }
}
