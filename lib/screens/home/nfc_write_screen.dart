import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:convert';

class NfcWriteScreen extends StatefulWidget {
  const NfcWriteScreen({super.key});

  @override
  _NfcWriteScreenState createState() => _NfcWriteScreenState();
}

class _NfcWriteScreenState extends State<NfcWriteScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();

  Future<void> writeNfc() async {
    try {
      // NFC 세션 시작
      var tag = await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          var ndef = Ndef.from(tag);
          if (ndef == null) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("❌ NDEF 태그가 아닙니다.")));
            NfcManager.instance.stopSession();
            return;
          }

          NdefMessage message = NdefMessage([
            NdefRecord.createText(_nameController.text),
            NdefRecord.createText(_contactController.text),
            NdefRecord.createText(_emailController.text),
            NdefRecord.createText(_jobController.text),
          ]);

          await ndef.write(message);

          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✅ NFC 태그에 정보 저장 성공")));
          NfcManager.instance.stopSession(); // 세션 종료
        },
      );
    } catch (e) {
      // 오류 처리
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("❌ NFC 저장 실패")));
    } finally {
      // 세션 종료
      NfcManager.instance.stopSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NFC 쓰기", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "이름"),
            ),
            TextField(
              controller: _contactController,
              decoration: const InputDecoration(labelText: "연락처"),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "이메일"),
            ),
            TextField(
              controller: _jobController,
              decoration: const InputDecoration(labelText: "직업"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: writeNfc,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text("NFC에 정보 저장", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
