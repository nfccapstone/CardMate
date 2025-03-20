import 'package:flutter/material.dart'; // ✅ 반드시 추가!
import 'package:get/get.dart';
import 'package:cardmate/services/nfc_write_service.dart';

class NfcWriteController extends GetxController {
  final NfcWriteService _nfcService = NfcWriteService();

  // 🔹 TextEditingController 선언
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // 🔹 NFC 데이터 쓰기 기능
  void writeNfcData() {
    _nfcService.writeNfcData(
      context: Get.context!,
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      company: companyController.text.trim(),
      position: positionController.text.trim(),
      address: addressController.text.trim(),
    );
  }

  // 🔹 컨트롤러 해제 (메모리 누수 방지)
  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    companyController.dispose();
    positionController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
