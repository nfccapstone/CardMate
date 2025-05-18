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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40),
              // 앱 로고 (CardMate)
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Card",
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: 2.5,
                      ),
                    ),
                    TextSpan(
                      text: "Mate",
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.blueAccent,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 입력창 + 로그인 관련 박스
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
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
                    const SizedBox(height: 20),

                    // 자동 로그인 스위치
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Auto Login",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87, // 가시성 향상
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Obx(() => Switch(
                              value: controller.isAutoLogin.value,
                              onChanged: (value) {
                                controller.isAutoLogin.value = value;
                              },
                              activeColor: Colors.black,
                              inactiveThumbColor: Colors.black,
                              inactiveTrackColor: Colors.grey.shade300,
                            )),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 로그인 버튼
                    ElevatedButton(
                      onPressed: controller.login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child:
                          const Text("LOGIN", style: TextStyle(fontSize: 16)),
                    ),

                    const SizedBox(height: 10),

                    // 계정 생성
                    TextButton(
                      onPressed: () => Get.toNamed('/register'),
                      child: const Text(
                        "CREATE ACCOUNT",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87, // 더 진한 색상
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Google 로그인
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
                    Image.asset('assets/images/google.png',
                        width: 24, height: 24),
                    const SizedBox(width: 10),
                    const Text(
                      "Sign in with Google",
                      style: TextStyle(color: Colors.black87),
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
