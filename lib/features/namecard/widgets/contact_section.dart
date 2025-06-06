// contact_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/features/namecard/controllers/contact_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSection extends StatelessWidget {
  final ContactController controller;
  const ContactSection({super.key, required this.controller});

  Future<void> _showDeleteDialog(String type, String value) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('연락처 삭제'),
        content: Text('$value를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await controller.deleteContact(type);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactTitles = {
      'mobile': '휴대전화',
      'phone': '유선전화',
      'email': '이메일',
      'address': '주소',
      'fax': '팩스',
    };

    return Obx(() {
      if (controller.contacts.isEmpty) return const SizedBox();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '연락처',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...['mobile', 'phone', 'email', 'address', 'fax']
              .where((type) => controller.contacts.containsKey(type))
              .map((type) {
                final value = controller.contacts[type] ?? '';
                IconData icon;
                List<Widget> actions = [];
                if (type == 'mobile' || type == 'phone' || type == 'phoneNumber') {
                  icon = Icons.phone;
                  actions = [
                    IconButton(
                      icon: const Icon(Icons.call, color: Colors.black87),
                      onPressed: () {
                        launchUrl(Uri.parse('tel:$value'));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.message, color: Colors.black87),
                      onPressed: () {
                        launchUrl(Uri.parse('sms:$value'));
                      },
                    ),
                  ];
                } else if (type == 'email') {
                  icon = Icons.email;
                  actions = [
                    IconButton(
                      icon: const Icon(Icons.email, color: Colors.black87),
                      onPressed: () {
                        launchUrl(Uri.parse('mailto:$value'));
                      },
                    ),
                  ];
                } else {
                  icon = Icons.contact_phone;
                }
                return GestureDetector(
                  onLongPress: () => _showDeleteDialog(type, value),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(icon, color: Colors.black87, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  value,
                                  style: const TextStyle(color: Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _showDeleteDialog(type, value),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ],
      );
    });
  }
}
