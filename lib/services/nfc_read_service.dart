import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcReadService {
  /// ✅ NFC 태그에서 명함 정보 읽기
  Future<String?> readNfcData(BuildContext context) async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ NFC 기능을 사용할 수 없습니다.")),
        );
        return null;
      }

      Completer<String?> completer = Completer(); // ✅ Completer 사용

      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          var ndef = Ndef.from(tag);
          if (ndef == null || ndef.cachedMessage == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("❌ 유효한 NFC 태그가 아닙니다.")),
            );
            completer.complete(null);
            await NfcManager.instance.stopSession();
            return;
          }

          // ✅ 첫 번째 레코드를 가져오기
          NdefRecord record = ndef.cachedMessage!.records.first;
          List<int> payloadBytes = record.payload; // 바이너리 데이터

          // ✅ 첫 바이트는 언어 코드 길이 정보 (예: 3 -> "ko")
          int langCodeLength = payloadBytes[0];

          // ✅ 언어 코드 이후 데이터만 추출하여 UTF-8로 변환
          String payload =
              utf8.decode(payloadBytes.sublist(langCodeLength + 1));

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ NFC 데이터 읽기 완료!")),
          );

          completer.complete(payload);

          await NfcManager.instance.stopSession();
        },
      );

      return completer.future;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ NFC 태그 인식 실패: $e")),
      );
      return null;
    }
  }
}
