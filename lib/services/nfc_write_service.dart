import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcWriteService {
  /// ✅ NFC 태그에 명함 정보 저장
  Future<void> writeNfcData({
    required BuildContext context,
    required String name,
    required String phone,
    required String email,
    required String company,
    required String position,
    required String address,
  }) async {
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
            await Future.delayed(Duration(milliseconds: 500));
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
}
