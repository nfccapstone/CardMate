import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class AddCardByNFCScreen extends StatefulWidget {
  @override
  _AddCardByNFCScreenState createState() => _AddCardByNFCScreenState();
}

class _AddCardByNFCScreenState extends State<AddCardByNFCScreen> {
  String tagData = '';

  void _startNfcSession() async {
    try {
      // NFC 태그를 기다림
      NFCTag tag = await FlutterNfcKit.poll();

      // 태그 정보 출력
      setState(() {
        tagData = 'ID: ${tag.id}\nType: ${tag.type}\nStandard: ${tag.standard}';
      });

      // 읽기 완료 후 세션 종료
      await FlutterNfcKit.finish();
    } catch (e) {
      setState(() {
        tagData = '에러 발생: $e';
      });
      await FlutterNfcKit.finish(); // 오류 발생해도 세션은 종료해야 함
    }
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
