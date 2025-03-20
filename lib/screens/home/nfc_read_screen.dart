import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/getX/controllers/nfc_read_controller.dart';

class NfcReadScreen extends StatelessWidget {
  const NfcReadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NfcReadController controller = Get.put(NfcReadController()); // 🔹 컨트롤러 주입

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
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 NFC 데이터 표시 (반응형 UI)
              Obx(() => Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[800], // Darker background for contrast
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Text(
                      controller.nfcData.value,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  )),
              const SizedBox(height: 30),
              // 🔹 NFC 스캔 버튼
              ElevatedButton(
                onPressed: controller.startNfcScan,
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
              // 🔹 NFC 데이터 저장 버튼
              ElevatedButton(
                onPressed: controller.saveNfcData,
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
