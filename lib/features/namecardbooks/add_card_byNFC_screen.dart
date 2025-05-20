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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("NFC 사용 불가")));
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
        // URI 레코드의 첫 바이트는 prefix, 이후가 실제 URI
        final url = utf8.decode(payload.sublist(1));
        setState(() {
          tagData = url;
        });
        // CardId 추출
        final cardId = url.split('/').last;
        await cardController.addCardById(cardId);

        Get.snackbar(
          '성공',
          '명함이 추가되었습니다.',
          snackPosition: SnackPosition.BOTTOM,
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
    NfcManager.instance.stopSession(); // 앱 종료 시 세션도 종료
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("NFC 명함 추가", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "NFC 명함 태그를\n스마트폰에 가까이 대세요",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            // NFC 아이콘 + 애니메이션(간단한 펄스 효과)
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: isScanning ? 140 : 120,
              height: isScanning ? 140 : 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.withOpacity(0.15),
                boxShadow: isScanning
                    ? [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 8,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Icon(Icons.nfc, size: 64, color: Colors.deepPurple),
              ),
            ),
            const SizedBox(height: 32),
            // 상태 메시지
            Text(
              isScanning
                  ? (tagData.isEmpty ? "NFC 태그를 기다리는 중..." : "명함 링크 인식 완료!")
                  : (tagData.isEmpty ? "스캔을 시작하세요" : tagData),
              style: TextStyle(
                color: tagData.isEmpty ? Colors.white70 : Colors.greenAccent,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            // 스캔 시작 버튼 (스캔 중에는 숨김)
            if (!isScanning)
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text("스캔 시작"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: _startNfcSession,
              ),
          ],
        ),
      ),
    );
  }
}
