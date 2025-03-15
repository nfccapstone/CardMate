import 'package:flutter/material.dart';
import 'register_service.dart'; // 회원가입 서비스 import

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterService _registerService = RegisterService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController companyController = TextEditingController();

  void _register() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }

    var user = await _registerService.signUp(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      phone: phoneController.text,
      position: positionController.text.isEmpty ? null : positionController.text,
      company: companyController.text.isEmpty ? null : companyController.text,
    );

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 성공! 로그인하세요.')),
      );
      Navigator.pop(context); // 회원가입 후 로그인 화면으로 이동
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 실패! 다시 시도하세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              Text("회원가입", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 30),
              _buildTextField(nameController, "이름", false),
              _buildTextField(emailController, "이메일", false, TextInputType.emailAddress),
              _buildTextField(passwordController, "비밀번호", true),
              _buildTextField(confirmPasswordController, "비밀번호 확인", true),
              _buildTextField(phoneController, "전화번호", false, TextInputType.phone),
              _buildTextField(positionController, "직책/직위 (선택)", false),
              _buildTextField(companyController, "회사명 (선택)", false),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, minimumSize: Size(double.infinity, 50)),
                child: Text("회원가입", style: TextStyle(fontSize: 18)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("로그인 화면으로 돌아가기", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool isPassword, [TextInputType keyboardType = TextInputType.text]) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white), borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent), borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
