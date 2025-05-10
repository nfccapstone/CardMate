import 'package:cardmate/features/namecardbooks/card_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/features/namecardbooks/i_other_contact_service.dart';
import 'package:cardmate/features/namecardbooks/card_model.dart';

class OtherContactController extends GetxController {
  final RxMap<String, Map<String, String>> allContacts =
      <String, Map<String, String>>{}.obs;
  final IOtherContactService _service;
  var cards = <CardModel>[].obs;
  late String cardId;

  final CardController cardController = Get.find<CardController>();

  OtherContactController({required IOtherContactService contactService})
      : _service = contactService;

  void setCardId(String id) {
    cardId = id;
    loadContacts(id);
  }

  Future<void> loadContacts(String cardId) async {
    final currentCard = cardController.cards.firstWhere(
      (c) => c.id == cardId,
    );
    allContacts[cardId] = currentCard.contacts!;
  }

  Map<String, String> getContactsForCard(String cardId) {
    return allContacts[cardId] ?? {};
  }

  Future<void> addContact(String cardId, String type, String value) async {
    try {
      await _service.saveContact(cardId, type, value);
      await loadContacts(cardId);
    } catch (_) {
      Get.snackbar('오류', '연락처 저장에 실패했어요.');
    }
  }

  Future<void> deleteContact(String type) async {
    try {
      final contacts = allContacts[cardId] ?? {};
      contacts.remove(type);
      allContacts[cardId] = contacts;
      await _service.saveContact(cardId, type, ''); // 빈 값으로 저장하여 삭제 효과
      Get.snackbar('성공', '연락처가 삭제되었습니다.');
    } catch (e) {
      Get.snackbar('오류', '연락처 삭제에 실패했습니다.');
    }
  }

  void showContactTypeSelector(BuildContext context, String cardId) {
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
              _buildContactTypeItem(context, '유선전화', 'phone', cardId),
              _buildContactTypeItem(context, '휴대전화', 'mobile', cardId),
              _buildContactTypeItem(context, '이메일', 'email', cardId),
              _buildContactTypeItem(context, '홈페이지', 'website', cardId),
              _buildContactTypeItem(context, '주소', 'address', cardId),
              _buildContactTypeItem(context, '팩스', 'fax', cardId),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactTypeItem(
      BuildContext context, String label, String type, String cardId) {
    return ListTile(
      leading: const Icon(Icons.chevron_right),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context);
        openContactEditor(context, cardId, type);
      },
    );
  }

  Future<void> openContactEditor(
      BuildContext context, String cardId, String type) async {
    final result = await Get.toNamed('/editContact', arguments: type);
    if (result != null && result['type'] != null && result['value'] != null) {
      await addContact(cardId, result['type'], result['value']);
    }
  }
}
