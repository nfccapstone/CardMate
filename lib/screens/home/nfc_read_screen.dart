import 'package:flutter/material.dart';
import 'package:cardmate/services/nfc_read_service.dart'; // ✅ NFC 서비스 추가

class NfcReadScreen extends StatefulWidget {
  const NfcReadScreen({super.key});

  @override
  _NfcReadScreenState createState() => _NfcReadScreenState();
}

class _NfcReadScreenState extends State<NfcReadScreen> {
  String _nfcData = "NFC 태그를 스캔하세요.";

  final NfcReadService _nfcService = NfcReadService(); // ✅ NFC 서비스 인스턴스 생성

  void _startNfcScan() async {
    String? result = await _nfcService.readNfcData(context);
    if (result != null) {
      setState(() {
        _nfcData = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "NFC 명함 읽기",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black, // ✅ 배경색 유지
        elevation: 4, // ✅ 그림자 추가 (입체감)
        shadowColor: Colors.grey.withOpacity(0.5), // ✅ 그림자 색상 조정
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기 기능
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display NFC data in a more stylish container
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[800], // Darker background for contrast
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Text(
                  _nfcData,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              // Scan button styled to match the theme
              ElevatedButton(
                onPressed: _startNfcScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Black background for button
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "📲  NFC 스캔",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
