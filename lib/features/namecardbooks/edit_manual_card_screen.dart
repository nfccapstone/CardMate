import 'package:cardmate/features/namecardbooks/contact_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/features/namecard/controllers/edit_card_controller.dart';
import 'package:cardmate/features/namecard/controllers/contact_controller.dart';
import 'package:cardmate/features/namecard/widgets/profile_section.dart';
import 'package:cardmate/features/namecard/services/i_contact_service.dart';
import 'package:cardmate/features/namecard/services/i_edit_card_service.dart';

class EditManualCardScreen extends StatelessWidget {
  final String cardId;
  late final EditCardController editController;

  EditManualCardScreen({Key? key, required this.cardId}) : super(key: key) {
    // 컨트롤러가 이미 존재하는지 확인
    if (!Get.isRegistered<EditCardController>()) {
      editController = Get.put(EditCardController(
        editCardService: Get.find<IEditCardService>(),
      ));
    } else {
      editController = Get.find<EditCardController>();
    }
    // 데이터 로드
    editController.loadManualCardDataByCardId(cardId);
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
        final List<Widget> children = [];
        // 프로필 카드
        children.add(_NonReorderable(
          key: const ValueKey('profile'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: ProfileSection(basicInfo: editController.otherBasicInfo),
          ),
        ));
        children.add(_NonReorderable(
            key: const ValueKey('profile_space'),
            child: const SizedBox(height: 12)));
        // 연락처 카드
        children.add(_NonReorderable(
          key: const ValueKey('contact'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: ContactSection(controller: contactController),
          ),
        ));
        children.add(_NonReorderable(
            key: const ValueKey('contact_space'),
            child: const SizedBox(height: 12)));
        children.add(_NonReorderable(
            key: const ValueKey('block_space'),
            child: const SizedBox(height: 20)));
        // 추가 버튼들
        children.add(_NonReorderable(
          key: const ValueKey('contact_add_btn'),
          child: _buildContactAddButton(context, contactController),
        ));
        children.add(_NonReorderable(
            key: const ValueKey('contact_add_space'),
            child: const SizedBox(height: 12)));
        children.add(_NonReorderable(
            key: const ValueKey('bottom_space'),
            child: const SizedBox(height: 40)));

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        );
      }),
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
}

class _NonReorderable extends StatelessWidget {
  final Widget child;
  const _NonReorderable({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) => child;
}
