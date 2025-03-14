import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 배경색 블랙
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // CardMate 로고
              Text(
                "회원가입",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 30),

              // 이름 입력 필드
              _buildTextField("이름", false),
              SizedBox(height: 12),

              // 이메일 입력 필드
              _buildTextField("이메일", false, TextInputType.emailAddress),
              SizedBox(height: 12),

              // 비밀번호 입력 필드
              _buildTextField("비밀번호", true),
              SizedBox(height: 12),

              // 비밀번호 확인 필드
              _buildTextField("비밀번호 확인", true),
              SizedBox(height: 12),

              // 전화번호 입력 필드 (필수)
              _buildTextField("전화번호", false, TextInputType.phone),
              SizedBox(height: 12),

              // 직책/직위 입력 필드 (선택)
              _buildTextField("직책/직위 (선택)", false),
              SizedBox(height: 12),

              // 회사명 입력 필드 (선택)
              _buildTextField("회사명 (선택)", false),
              SizedBox(height: 24),

              // 회원가입 버튼
              ElevatedButton(
                onPressed: () {
                  // 회원가입 기능 추가 예정
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 50), // 버튼 크기 조정
                ),
                child: Text("회원가입", style: TextStyle(fontSize: 18)),
              ),
              SizedBox(height: 12),

              // 로그인으로 이동 버튼
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // 로그인 화면으로 돌아가기
                },
                child: Text(
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

  // 공통 텍스트 필드 위젯
  Widget _buildTextField(String label, bool isPassword, [TextInputType keyboardType = TextInputType.text]) {
    return TextField(
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
