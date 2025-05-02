// contact_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/features/namecard/controllers/contact_controller.dart';
import 'package:url_launcher/url_launcher.dart';

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
          } else if (type == 'website') {
            icon = Icons.language;
            actions = [
              IconButton(
                icon: const Icon(Icons.open_in_browser, color: Colors.black87),
                onPressed: () {
                  launchUrl(Uri.parse(value));
                },
              ),
            ];
          } else {
            icon = Icons.contact_phone;
          }
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
                Icon(icon, color: Colors.deepPurple),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contactTitles[type] ?? type,
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
                ...actions,
              ],
            ),
          );
        }).toList(),
      );
    });
  }
}
