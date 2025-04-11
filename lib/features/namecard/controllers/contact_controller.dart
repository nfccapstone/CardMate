import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/features/namecard/services/i_contact_service.dart';

class ContactController extends GetxController {
  final contacts = <String, String>{}.obs;
  final IContactService _service;

  // DI: IContactService 구현체를 생성자 주입
  ContactController({required IContactService contactService})
      : _service = contactService;

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
      await loadContacts();
    } catch (_) {
      Get.snackbar('오류', '연락처 저장에 실패했어요.');
    }
  }

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

  Widget _buildContactTypeItem(BuildContext context, String label, String type) {
    return ListTile(
      leading: const Icon(Icons.chevron_right),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context);
        openContactEditor(context, type);
      },
    );
  }

  Future<void> openContactEditor(BuildContext context, String type) async {
    final result = await Get.toNamed('/editContact', arguments: type);
    if (result != null && result['type'] != null && result['value'] != null) {
      await addContact(result['type'], result['value']);
    }
  }
}
