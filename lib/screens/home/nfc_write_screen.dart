import 'package:flutter/material.dart';
import 'package:cardmate/services/nfc_write_service.dart';
import 'package:cardmate/screens/home/home_screen.dart'; // 홈 화면 import

class NfcWriteScreen extends StatefulWidget {
  const NfcWriteScreen({super.key});

  @override
  _NfcWriteScreenState createState() => _NfcWriteScreenState();
}

class _NfcWriteScreenState extends State<NfcWriteScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final NfcWriteService _nfcService = NfcWriteService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "NFC 명함 저장",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context); // 이전 화면이 있으면 pop 실행
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()), // 홈 화면으로 이동
              );
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildInputField(_nameController, "이름", Icons.person),
              const SizedBox(height: 12),
              _buildInputField(_phoneController, "전화번호", Icons.phone),
              const SizedBox(height: 12),
              _buildInputField(_emailController, "이메일", Icons.email),
              const SizedBox(height: 12),
              _buildInputField(_companyController, "소속", Icons.business),
              const SizedBox(height: 12),
              _buildInputField(_positionController, "직함", Icons.badge),
              const SizedBox(height: 12),
              _buildInputField(_addressController, "주소", Icons.location_on),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _nfcService.writeNfcData(
                      context: context,
                      name: _nameController.text.trim(),
                      phone: _phoneController.text.trim(),
                      email: _emailController.text.trim(),
                      company: _companyController.text.trim(),
                      position: _positionController.text.trim(),
                      address: _addressController.text.trim(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "💾  NFC에 정보 저장",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 **공통된 입력 필드 디자인 함수**
  Widget _buildInputField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white), // Label text to white
        prefixIcon: Icon(icon, color: Colors.white), // Icon color to white
        filled: true,
        fillColor: Colors.black, // Background to black
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      style: const TextStyle(color: Colors.white), // Input text to white
      cursorColor: Colors.white, // Cursor color to white
    );
  }
}
