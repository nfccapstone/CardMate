import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/getX/controllers/edit_card_controller.dart';

class EditCardScreen extends StatelessWidget {
  const EditCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditCardController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('디지털 명함 편집', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildNameCardPreview(controller),
                  const SizedBox(height: 20),
                  _buildContactList(controller), // ✅ 연락처 표시
                  const SizedBox(height: 20),
                  _buildContactAddButton(context),
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
          controller.loadNameCardData(); // ✅ 사용자가 뒤로 올 때 반영됨
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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

  void _showContactTypeSelector(BuildContext context) {
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
      Navigator.pop(context); // 바텀시트 닫기
      Get.toNamed('/editContact', arguments: type); // 연락처 입력 화면으로 이동 (route 설정 필요)
    },
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

  Widget _buildContactAddButton(BuildContext context) {
  return GestureDetector(
    onTap: () => _showContactTypeSelector(context),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        '+ 연락처 추가',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
      ),
    ),
  );
}
Widget _buildContactList(EditCardController controller) {
  final contactIcons = {
    'mobile': Icons.phone_android,
    'phone': Icons.phone,
    'email': Icons.email,
    'website': Icons.language,
    'address': Icons.location_on,
    'fax': Icons.print,
  };

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
                    Text(
                      contactTitles[type] ?? '연락처',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
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
                  onPressed: () {
                    // 전화 연결 기능도 추후 추가 가능
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.message, color: Colors.black87),
                  onPressed: () {
                    // 문자 메시지 기능도 추후 추가 가능
                  },
                ),
              ]
            ],
          ),
        );
      }).toList(),
    );
  });
}
}