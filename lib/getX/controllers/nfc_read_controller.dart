//import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/services/nfc_read_service.dart';
import 'package:cardmate/services/business_card_registration_service.dart';

class NfcReadController extends GetxController {
  final NfcReadService _nfcService = NfcReadService();
  final BusinessCardRegistrationService _registrationService =
      BusinessCardRegistrationService();

  var nfcData = "NFC 태그를 스캔하세요.".obs; // 🔹 NFC 데이터를 반응형 변수로 관리

  void startNfcScan() async {
    String? result = await _nfcService.readNfcData(Get.context!);
    if (result != null) {
      nfcData.value = result; // 🔹 상태 업데이트 (UI 자동 변경됨)
    }
  }

  Future<void> saveNfcData() async {
    await _registrationService.saveNfcDataToFirebase(nfcData.value);
  }
}
