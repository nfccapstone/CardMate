import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/i_login_service.dart';

class LoginController extends GetxController {
  final ILoginService _loginService;
  final _prefs = SharedPreferences.getInstance();

  LoginController({required ILoginService loginService})
      : _loginService = loginService;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var isAutoLogin = false.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await _prefs;
      final email = prefs.getString('email');
      final password = prefs.getString('password');
      
      if (email != null && password != null) {
        emailController.text = email;
        passwordController.text = password;
        isAutoLogin.value = true;
        
        // 자동 로그인 시도
        final user = await _loginService.signIn(email, password);
        if (user != null) {
          Get.offAllNamed('/home');
          return;
        }
      }
    } catch (e) {
      print('자동 로그인 실패: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login() async {
    try {
      isLoading.value = true;
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      var user = await _loginService.signIn(email, password);

      if (user != null) {
        if (isAutoLogin.value) {
          await _saveCredentials(email, password);
        }
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
      _handleLoginError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveCredentials(String email, String password) async {
    final prefs = await _prefs;
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

  Future<void> loginWithGoogle() async {
    try {
      var user = await _loginService.signInWithGoogle();
      if (user != null) {
        Get.snackbar("로그인 성공", "구글 계정으로 로그인되었습니다.");
      } else {
        Get.snackbar("로그인 취소됨", "구글 로그인이 취소되었습니다.");
      }
    } catch (e) {
      Get.snackbar("오류", "구글 로그인 중 오류가 발생했습니다.",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  void _handleLoginError(Object e) {
    if (e is FirebaseAuthException) {
      if (e.code == 'invalid-credential') {
        Get.snackbar(
          "이메일 또는 비밀번호가 올바르지 않습니다.",
          "다시 확인해주세요.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
        );
      } else {
        Get.snackbar(
          "오류",
          "로그인 중 오류가 발생했습니다.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
        );
      }
    } else {
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
