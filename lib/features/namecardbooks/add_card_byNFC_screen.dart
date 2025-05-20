import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:get/get.dart';
import 'package:cardmate/features/namecardbooks/card_controller.dart';
import 'dart:convert';
import 'package:cardmate/features/home/home_controller.dart';

class AddCardByNFCScreen extends StatefulWidget {
  @override
  _AddCardByNFCScreenState createState() => _AddCardByNFCScreenState();
}

class _AddCardByNFCScreenState extends State<AddCardByNFCScreen> {
  String tagData = '';
  bool isScanning = false;
  final CardController cardController = Get.find<CardController>();

  void _startNfcSession() async {
    setState(() {
      isScanning = true;
      tagData = '';
    });
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      Get.snackbar(
        '오류',
        'NFC 사용 불가',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      setState(() {
        isScanning = false;
      });
      return;
    }

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        final ndef = Ndef.from(tag);
        if (ndef == null) throw Exception('NDEF 지원 불가 태그');
        final cachedMessage = ndef.cachedMessage;
        if (cachedMessage == null || cachedMessage.records.isEmpty)
          throw Exception('NDEF 메시지 없음');

        final payload = cachedMessage.records.first.payload;
        final url = utf8.decode(payload.sublist(1));
        setState(() {
          tagData = url;
        });
        final cardId = url.split('/').last;
        await cardController.addCardById(cardId);

        Get.snackbar(
          '성공',
          '명함이 추가되었습니다.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
        await NfcManager.instance.stopSession();
        setState(() {
          isScanning = false;
        });
        Get.until((route) => route.settings.name == '/home');
      } catch (e) {
        Get.snackbar(
          '오류',
          '명함 추가 중 오류가 발생했습니다. (${e.toString()})',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
        await NfcManager.instance.stopSession();
        setState(() {
          isScanning = false;
        });
      }
    });
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "NFC 명함 추가",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  const Text(
                    "NFC 명함 태그를\n스마트폰에 가까이 대세요",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: isScanning ? 140 : 120,
                    height: isScanning ? 140 : 120,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isScanning
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 30,
                                spreadRadius: 8,
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.nfc,
                        size: 64,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      isScanning
                          ? (tagData.isEmpty
                              ? "NFC 태그를 기다리는 중..."
                              : "명함 링크 인식 완료!")
                          : (tagData.isEmpty ? "스캔을 시작하세요" : tagData),
                      style: TextStyle(
                        color: tagData.isEmpty
                            ? Colors.black54
                            : Colors.green,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            if (!isScanning)
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text("스캔 시작"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: _startNfcSession,
              ),
          ],
        ),
      ),
    );
  }
}
