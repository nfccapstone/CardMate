import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'register_controller.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // GetX 바인딩을 통해 등록된 컨트롤러를 가져옵니다.
    final RegisterController controller = Get.find<RegisterController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const Text(
                "회원가입",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(controller.nameController, "이름", false),
              const SizedBox(height: 12),
              _buildTextField(controller.emailController, "이메일", false, TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildTextField(controller.passwordController, "비밀번호", true),
              const SizedBox(height: 12),
              _buildTextField(controller.confirmPasswordController, "비밀번호 확인", true),
              const SizedBox(height: 12),
              _buildTextField(controller.phoneController, "전화번호", false, TextInputType.phone),
              const SizedBox(height: 12),
              _buildTextField(controller.positionController, "직책/직위 (선택)", false),
              const SizedBox(height: 12),
              _buildTextField(controller.companyController, "회사명 (선택)", false),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: controller.register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("회원가입", style: TextStyle(fontSize: 18)),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  "로그인 화면으로 돌아가기",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, bool isPassword,
      [TextInputType keyboardType = TextInputType.text]) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
