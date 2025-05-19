import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:get/get.dart';
import 'package:cardmate/features/namecardbooks/card_controller.dart';

class AddCardByNFCScreen extends StatefulWidget {
  @override
  _AddCardByNFCScreenState createState() => _AddCardByNFCScreenState();
}

class _AddCardByNFCScreenState extends State<AddCardByNFCScreen> {
  String tagData = '';
  final CardController cardController = Get.find<CardController>();

  void _startNfcSession() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("NFC 사용 불가")));
      return;
    }

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        var id = tag.data['nfca']?['identifier'];
        if (id != null) {
          // 명함 추가
          await cardController.addCardById(id.toString());
          
          // 성공 메시지 표시
          Get.snackbar(
            '성공',
            '명함이 추가되었습니다.',
            snackPosition: SnackPosition.BOTTOM,
          );
          
          // 세션 종료
          NfcManager.instance.stopSession();
          
          // 명함첩 화면으로 돌아가기
          Get.back();
        }
      } catch (e) {
        Get.snackbar(
          '오류',
          '명함 추가 중 오류가 발생했습니다.',
          snackPosition: SnackPosition.BOTTOM,
        );
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
      appBar: AppBar(title: Text("NFC 태그 읽기")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tagData.isEmpty ? 'NFC 태그를 스캔하세요' : tagData),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startNfcSession,
              child: Text('스캔 시작'),
            ),
          ],
        ),
      ),
    );
  }
}
