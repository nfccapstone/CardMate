// contact_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/features/namecard/controllers/contact_controller.dart';

class ContactSection extends StatelessWidget {
  final ContactController controller;
  const ContactSection({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        children: controller.contacts.entries.map((entry) {
          final type = entry.key;
          final value = entry.value;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contactTitles[type] ?? '연락처',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
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
                ],
              ],
            ),
          );
        }).toList(),
      );
    });
  }
}
