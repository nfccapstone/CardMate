import 'package:flutter/material.dart';
import 'package:cardmate/services/nfc_write_service.dart'; // ✅ NFC 서비스 추가

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

  final NfcWriteService _nfcService = NfcWriteService(); // ✅ NFC 서비스 인스턴스 생성

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NFC 명함 저장", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: "이름")),
              TextField(controller: _phoneController, decoration: const InputDecoration(labelText: "전화번호")),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: "이메일")),
              TextField(controller: _companyController, decoration: const InputDecoration(labelText: "소속")),
              TextField(controller: _positionController, decoration: const InputDecoration(labelText: "직함")),
              TextField(controller: _addressController, decoration: const InputDecoration(labelText: "주소")),
              const SizedBox(height: 20),
              ElevatedButton(
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
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("📌 NFC에 정보 저장", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
