import 'package:cardmate/features/namecardbooks/i_other_contact_service.dart';
import 'package:cardmate/features/namecardbooks/other_contact_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/features/namecardbooks/other_contact_controller.dart';
import 'package:cardmate/features/namecardbooks/card_controller.dart';
import 'package:cardmate/features/namecardbooks/edit_card_info_screen.dart';
import 'package:cardmate/features/namecardbooks/card_model.dart';
import 'package:cardmate/features/namecard/services/i_contact_service.dart';

class EditOtherCardScreen extends StatelessWidget {
  final CardModel card;
  const EditOtherCardScreen({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final cardController = Get.put(CardController());
    final contactController = Get.put(
        OtherContactController(contactService: Get.put(OtherContactService())));

    // 이 카드의 연락처 불러오기
    contactController.loadContacts(card.id);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('디지털 명함 편집', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Obx(() {
        final currentCard = cardController.cards.firstWhere(
          (c) => c.id == card.id,
          orElse: () => card,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildNameCardPreview(currentCard),
              const SizedBox(height: 20),
              _buildContactList(contactController, card.id),
              const SizedBox(height: 20),
              _buildContactAddButton(context, contactController, card.id),
              const Divider(height: 40, color: Colors.white24),
              _buildAddButton('+ 연락처 추가'),
              const Divider(height: 40, color: Colors.white24),
              _buildAddButton('+ 블록 추가'),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildNameCardPreview(CardModel card) {
    return GestureDetector(
      onTap: () async {
        final result = await Get.to(EditCardScreen2(card: card));
        if (result == true) {
          Get.find<CardController>().fetchCards(); // reload
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green[700],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.name,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              '${card.department} / ${card.position}',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              card.company,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                textStyle: const TextStyle(fontSize: 14),
              ),
              child: const Text('+ 태그 추가'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildContactList(OtherContactController controller, String cardId) {
    final contactTitles = {
      'mobile': '휴대전화',
      'phone': '유선전화',
      'email': '이메일',
      'website': '홈페이지',
      'address': '주소',
      'fax': '팩스',
    };

    final contacts = controller.getContactsForCard(cardId);

    if (contacts.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contacts.entries.map((entry) {
        final type = entry.key;
        final value = entry.value;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          margin: const EdgeInsets.only(bottom: 1),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contactTitles[type] ?? '연락처',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (type == 'mobile' || type == 'phone') ...[
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.black87),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.message, color: Colors.black87),
                  onPressed: () {},
                ),
              ]
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactAddButton(
      BuildContext context, OtherContactController controller, String cardId) {
    return GestureDetector(
      onTap: () => controller.showContactTypeSelector(context, cardId),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          '+ 연락처 추가',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildAddButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}
