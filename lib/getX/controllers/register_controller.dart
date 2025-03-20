import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/services/register_service.dart';

class RegisterController extends GetxController {
  final RegisterService _registerService = RegisterService();

  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var phoneController = TextEditingController();
  var positionController = TextEditingController();
  var companyController = TextEditingController();

  Future<void> register() async {
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar("회원가입 실패", "비밀번호가 일치하지 않습니다.",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      return;
    }

    var user = await _registerService.signUp(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      phone: phoneController.text.trim(),
      position: positionController.text.trim().isEmpty ? null : positionController.text.trim(),
      company: companyController.text.trim().isEmpty ? null : companyController.text.trim(),
    );

    if (user != null) {
      Get.snackbar("회원가입 성공", "로그인 화면으로 이동합니다.",
          snackPosition: SnackPosition.BOTTOM);
      Get.back(); // 로그인 화면으로 이동
    } else {
      Get.snackbar("회원가입 실패", "다시 시도하세요.",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
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
