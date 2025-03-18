import 'package:flutter/material.dart';
import 'package:cardmate/services/nfc_read_service.dart';
import 'package:cardmate/services/business_card_registration_service.dart';
import '../home/home_screen.dart';

class NfcReadScreen extends StatefulWidget {
  const NfcReadScreen({super.key});

  @override
  _NfcReadScreenState createState() => _NfcReadScreenState();
}

class _NfcReadScreenState extends State<NfcReadScreen> {
  String _nfcData = "NFC 태그를 스캔하세요.";

  final NfcReadService _nfcService = NfcReadService();
  final BusinessCardRegistrationService _registrationService =
      BusinessCardRegistrationService();

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
        backgroundColor: Colors.black,
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context); // 뒤로 가기
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen()), // 홈 화면으로 이동
              );
            }
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
              ElevatedButton(
                onPressed: () async {
                  await _registrationService.saveNfcDataToFirebase(_nfcData);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Black background for button
                  padding:
                      const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "📇  명함 등록",
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
