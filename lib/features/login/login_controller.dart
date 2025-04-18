import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'services/i_login_service.dart';

class LoginController extends GetxController {
  final ILoginService _loginService;

  // 의존성 주입: ILoginService 구현체를 생성자 파라미터로 받습니다.
  LoginController({required ILoginService loginService})
      : _loginService = loginService;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    try {
      var user = await _loginService.signIn(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        Get.snackbar("로그인 성공", "홈 화면으로 이동합니다.");
        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          "로그인 실패",
          "이메일과 비밀번호를 확인하세요.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Get.snackbar(
        "오류",
        "로그인 중 예기치 못한 오류가 발생했습니다.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
