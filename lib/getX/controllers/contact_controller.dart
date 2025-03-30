import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/services/contact_service.dart';

class ContactController extends GetxController {
  final contacts = <String, String>{}.obs;
  final ContactService _service = ContactService();

  @override
  void onInit() {
    super.onInit();
    loadContacts();
  }

  Future<void> loadContacts() async {
    final data = await _service.fetchContacts();
    if (data != null) {
      contacts.assignAll(data);
    }
  }

  Future<void> addContact(String type, String value) async {
    try {
      await _service.saveContact(type, value);
      await loadContacts(); // 새로고침
    } catch (_) {
      Get.snackbar('오류', '연락처 저장에 실패했어요.');
    }
  }

  /// 연락처 유형 선택 바텀시트 표시
  void showContactTypeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '연락처 추가',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              _buildContactTypeItem(context, '유선전화', 'phone'),
              _buildContactTypeItem(context, '휴대전화', 'mobile'),
              _buildContactTypeItem(context, '이메일', 'email'),
              _buildContactTypeItem(context, '홈페이지', 'website'),
              _buildContactTypeItem(context, '주소', 'address'),
              _buildContactTypeItem(context, '팩스', 'fax'),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  /// 연락처 유형 버튼 생성
  Widget _buildContactTypeItem(BuildContext context, String label, String type) {
    return ListTile(
      leading: const Icon(Icons.chevron_right),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context); // 바텀시트 닫기
        openContactEditor(context, type); // 입력 화면 이동
      },
    );
  }

  /// 연락처 입력 화면 이동 및 저장 처리
  Future<void> openContactEditor(BuildContext context, String type) async {
    final result = await Get.toNamed('/editContact', arguments: type);

    if (result != null && result['type'] != null && result['value'] != null) {
      await addContact(result['type'], result['value']);
    }
  }
}
