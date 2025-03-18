import 'package:get/get.dart';
import 'package:cardmate/services/login_service.dart';
import 'package:flutter/material.dart'; // ✅ 반드시 추가!

class LoginController extends GetxController {
  final LoginService _loginService = LoginService();

  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  Future<void> login() async {
    var user = await _loginService.signIn(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (user != null) {
      Get.snackbar("로그인 성공", "홈 화면으로 이동합니다.");
      Get.offAllNamed('/home');
    } else {
      Get.snackbar("로그인 실패", "이메일과 비밀번호를 확인하세요.",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
