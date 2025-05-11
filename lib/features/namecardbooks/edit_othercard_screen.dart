import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/features/namecard/controllers/edit_card_controller.dart';
import 'package:cardmate/features/namecard/controllers/contact_controller.dart';
import 'package:cardmate/features/namecard/widgets/profile_section.dart';
import 'package:cardmate/features/namecard/widgets/contact_section.dart';
import 'package:cardmate/features/namecard/widgets/block_section.dart';
import 'package:cardmate/features/namecard/widgets/sns_bottom_sheet.dart';
import 'package:cardmate/features/namecard/services/i_contact_service.dart';
import 'package:cardmate/features/namecard/services/i_edit_card_service.dart';

class EditOtherCardScreen extends StatelessWidget {
  final String cardId;
  late final EditCardController editController;

  EditOtherCardScreen({Key? key, required this.cardId}) : super(key: key) {
    // 컨트롤러가 이미 존재하는지 확인
    if (!Get.isRegistered<EditCardController>()) {
      editController = Get.put(EditCardController(
        editCardService: Get.find<IEditCardService>(),
      ));
    } else {
      editController = Get.find<EditCardController>();
    }
    // 데이터 로드
    editController.loadNameCardDataByCardId(cardId);
  }

  @override
  Widget build(BuildContext context) {
    final contactController = Get.put(
      ContactController(
        contactService: Get.find<IContactService>(),
        cardId: cardId,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '디지털 명함',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (editController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileSection(basicInfo: editController.otherBasicInfo),
              const SizedBox(height: 20),
              ContactSection(controller: contactController),
              const SizedBox(height: 20),
              BlockSection(blocks: editController.otherBlocks),
              const SizedBox(height: 20),
              _buildContactAddButton(context, contactController),
              const SizedBox(height: 12),
              _buildBlockAddButton(context, editController),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
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
      BuildContext context, ContactController controller) {
    return GestureDetector(
      onTap: () => controller.showContactTypeSelector(context),
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

  Widget _buildBlockAddButton(
      BuildContext context, EditCardController controller) {
    return GestureDetector(
      onTap: () => _showBlockTypeBottomSheet(controller),
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

  void _showBlockTypeBottomSheet(EditCardController controller) {
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
              onTap: () => _navigateToBlockCreateScreen('text', controller),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('링크 블록'),
              onTap: () => _navigateToBlockCreateScreen('link', controller),
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('사진 블록'),
              onTap: () => _navigateToBlockCreateScreen('photo', controller),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToBlockCreateScreen(
      String blockType, EditCardController controller) async {
    Get.back(); // BottomSheet 닫기
    final result = await Get.toNamed(
      '/blockCreate',
      arguments: {'type': blockType},
    );
    if (result != null && result is Map<String, dynamic>) {
      controller.addBlock(result);
    }
  }
}
