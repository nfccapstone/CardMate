import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/getX/controllers/edit_card_controller.dart';
import 'package:cardmate/getX/controllers/contact_controller.dart';

class EditCardScreen extends StatelessWidget {
  const EditCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final editController = Get.put(EditCardController());
    final contactController = Get.put(ContactController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('디지털 명함 편집', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Obx(() => editController.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildNameCardPreview(editController),
                  const SizedBox(height: 20),
                  _buildContactList(contactController),
                  const SizedBox(height: 20),
                  _buildContactAddButton(context, contactController),
                  const Divider(height: 40, color: Colors.white24),
                  _buildAddButton('+ 블록 추가'),
                ],
              ),
            )),
    );
  }

  Widget _buildNameCardPreview(EditCardController controller) {
    final data = controller.basicInfo;
    return GestureDetector(
      onTap: () async {
        final result = await Get.toNamed('/namecardInfo');
        if (result == true) {
          controller.loadNameCardData(); // ✅ 돌아왔을 때 다시 불러옴
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
              data['name'] ?? '이름 없음',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              '${data['department'] ?? ''} / ${data['position'] ?? ''}',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              data['company'] ?? '',
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

  Widget _buildContactList(ContactController controller) {
    final contactTitles = {
      'mobile': '휴대전화',
      'phone': '유선전화',
      'email': '이메일',
      'website': '홈페이지',
      'address': '주소',
      'fax': '팩스',
    };

    return Obx(() {
      if (controller.contacts.isEmpty) return const SizedBox();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: controller.contacts.entries.map((entry) {
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
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey)),
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
                    onPressed: () {}, // 이후 연결
                  ),
                  IconButton(
                    icon: const Icon(Icons.message, color: Colors.black87),
                    onPressed: () {}, // 이후 연결
                  ),
                ]
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildContactAddButton(
      BuildContext context, ContactController controller) {
    return GestureDetector(
      onTap: () => controller.showContactTypeSelector(context),
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
