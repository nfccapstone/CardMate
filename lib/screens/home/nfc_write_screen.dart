import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

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

  /// ✅ NFC 태그에 명함 정보 저장
  Future<void> _writeNFC() async {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String email = _emailController.text.trim();
    String company = _companyController.text.trim();
    String position = _positionController.text.trim();
    String address = _addressController.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty || company.isEmpty || position.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ 모든 정보를 입력해주세요.")),
      );
      return;
    }

    String nfcData = """
이름: $name
전화번호: $phone
이메일: $email
소속: $company
직함: $position
주소: $address
""";

    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          var ndef = Ndef.from(tag);

          if (ndef == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("❌ NDEF 태그가 아닙니다.")),
            );
            await NfcManager.instance.stopSession();
            return;
          }

          if (!ndef.isWritable) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("❌ 쓰기 불가능한 NFC 태그입니다.")),
            );
            await NfcManager.instance.stopSession();
            return;
          }

          NdefMessage message = NdefMessage([
            NdefRecord.createText(nfcData),
          ]);

          try {
            await ndef.write(message);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✅ NFC 태그에 명함 정보 저장 완료!")),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("❌ NFC 저장 실패: $e")),
            );
          } finally {
            await Future.delayed(Duration(milliseconds: 500)); // ✅ NFC 세션이 너무 빨리 종료되지 않도록 약간의 딜레이 추가
            await NfcManager.instance.stopSession();
          }
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ NFC 태그 인식 실패: $e")),
      );
    }
  }

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
                onPressed: _writeNFC,
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
