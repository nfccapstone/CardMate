import 'package:cardmate/features/namecardbooks/i_other_contact_service.dart';
import 'package:cardmate/features/namecardbooks/other_contact_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/features/namecardbooks/other_contact_controller.dart';
import 'package:cardmate/features/namecardbooks/card_controller.dart';
import 'package:cardmate/features/namecardbooks/card_model.dart';
import 'package:cardmate/features/namecardbooks/widgets/profile_section.dart';
import 'package:cardmate/features/namecardbooks/widgets/contact_section.dart';

class EditOtherCardScreen extends StatelessWidget {
  final CardModel card;
  const EditOtherCardScreen({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final cardController = Get.put(CardController());
    final contactController = Get.put(
        OtherContactController(contactService: Get.put(OtherContactService())));

    // 카드 ID 설정 및 연락처 불러오기
    contactController.setCardId(card.id);

    return Scaffold(
      backgroundColor: Colors.white,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileSection(basicInfo: currentCard),
              const SizedBox(height: 20),
              ContactSection(controller: contactController),
              const SizedBox(height: 20),
              _buildContactAddButton(context, contactController),
              const SizedBox(height: 12),
              _buildBlockAddButton(context),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          // SNS 목록 및 추가 기능 BottomSheet 표시
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => const SNSBottomSheetUI(),
          );
        },
        child: const Icon(Icons.public),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildContactAddButton(
      BuildContext context, OtherContactController controller) {
    return GestureDetector(
      onTap: () => controller.showContactTypeSelector(context, card.id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          '+ 연락처 추가',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBlockAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBlockTypeBottomSheet(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          '+ 블록 추가',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showBlockTypeBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('텍스트 블록'),
              onTap: () => _navigateToBlockCreateScreen('text'),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('링크 블록'),
              onTap: () => _navigateToBlockCreateScreen('link'),
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('사진 블록'),
              onTap: () => _navigateToBlockCreateScreen('photo'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToBlockCreateScreen(String blockType) async {
    Get.back(); // BottomSheet 닫기
    final result = await Get.toNamed(
      '/blockCreate',
      arguments: {'type': blockType},
    );
    if (result != null && result is Map<String, dynamic>) {
      // TODO: 블록 추가 로직 구현
    }
  }
}

class SNSBottomSheetUI extends StatelessWidget {
  const SNSBottomSheetUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'SNS 추가',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildSNSItem(Icons.facebook, 'Facebook'),
          _buildSNSItem(Icons.camera_alt, 'Instagram'),
          _buildSNSItem(Icons.link, 'LinkedIn'),
          _buildSNSItem(Icons.chat, 'KakaoTalk'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSNSItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        // TODO: SNS 추가 로직 구현
        Get.back();
      },
    );
  }
}
