import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../getX/controllers/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 150),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFF004AAD),
                        Color.fromARGB(255, 8, 142, 187)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text(
                      "CardMate",
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(
                          158, 215, 242, 1), // 블루 계열 로그인 박스
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTextField(
                          controller.emailController,
                          "이메일",
                          false,
                          Icons.mail,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller.passwordController,
                          "비밀번호",
                          true,
                          Icons.lock,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(
                                  1, 73, 123, 1), // 버튼 색상 변경
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text("로그인",
                                style: TextStyle(fontSize: 18)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Get.toNamed('/register'),
                          child: const Text(
                            "회원가입",
                            style: TextStyle(
                                color: Color.fromRGBO(1, 73, 123, 1),
                                fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      bool isPassword, IconData icon) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromRGBO(200, 230, 250, 1), // 입력 필드 배경 색상 변경
        prefixIcon:
            Icon(icon, color: const Color.fromRGBO(1, 73, 123, 1)), // 아이콘 색상 변경
        labelText: label,
        labelStyle: const TextStyle(
            color: Color.fromRGBO(1, 73, 123, 1)), // 입력 필드 글자 색상 변경
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
              color: Color.fromRGBO(1, 73, 123, 1)), // 포커스 테두리 색상 변경
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
