import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "CardMate",
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),
              Column(
                children: [
                  _buildInputField(
                    controller.emailController,
                    "Email",
                    Icons.person,
                    false,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller.passwordController,
                    "Password",
                    Icons.lock,
                    true,
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // 자동 로그인 체크박스 추가
              // 자동 로그인 체크박스 부분 수정
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "자동 로그인",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87, // 텍스트 색상 일치
                    ),
                  ),
                  Obx(() => Switch(
                        value: controller.isAutoLogin.value,
                        onChanged: (value) {
                          controller.isAutoLogin.value = value;
                        },
                        activeColor: Colors.black, // 스위치 슬라이더 색
                        activeTrackColor: Colors.black26, // 스위치 배경 색
                        inactiveThumbColor:
                            const Color.fromARGB(255, 0, 0, 0), // 비활성 슬라이더
                        inactiveTrackColor: Colors.grey.shade300, // 비활성 배경
                      )),
                ],
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: controller.login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  "LOGIN",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 7),

              Column(
                children: [
                  TextButton(
                    onPressed: () => Get.toNamed('/register'),
                    child: const Text(
                      "CREATE ACCOUNT",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 1,
                    color: Colors.black26,
                  ),
                ],
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: controller.loginWithGoogle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 구글 아이콘 이미지 추가
                    Image.asset(
                      'assets/images/google.png', // 경로에 맞게 수정
                      width: 24, // 원하는 크기로 설정
                      height: 24, // 원하는 크기로 설정
                    ),
                    const SizedBox(width: 8), // 텍스트와 아이콘 사이의 간격
                    const Text(
                      "Sign in with Google",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String hint,
    IconData icon,
    bool isPassword,
  ) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              style: const TextStyle(color: Colors.black87),
              cursorColor: Colors.grey,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
