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

class _AddCardByNFCScreenState extends State<AddCardByNFCScreen> with SingleTickerProviderStateMixin {
  String tagData = '';
  bool isScanning = false;
  final CardController cardController = Get.find<CardController>();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

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
    _pulseController.dispose();
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 320,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 24),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isScanning)
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue.withOpacity(0.15),
                                  ),
                                ),
                              );
                            },
                          ),
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/icons/NFCScan.png',
                              width: 56,
                              height: 56,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        isScanning
                            ? (tagData.isEmpty
                                ? "NFC 태그를 기다리는 중..."
                                : "명함 링크 인식 완료!")
                            : (tagData.isEmpty ? "스캔을 시작하세요" : tagData),
                        style: TextStyle(
                          color: tagData.isEmpty ? Colors.black54 : Colors.green,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
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
      ),
    );
  }
}
