import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/features/namecardbooks/other_contact_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSection extends StatelessWidget {
  final OtherContactController controller;

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

    final contactIcons = {
      'mobile': Icons.phone_android,
      'phone': Icons.phone,
      'email': Icons.email,
      'website': Icons.language,
      'address': Icons.location_on,
      'fax': Icons.fax,
    };

    return Obx(() {
      final contacts = controller.allContacts[controller.cardId] ?? {};

      if (contacts.isEmpty) {
        return const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: contacts.entries.map((entry) {
          final type = entry.key;
          final value = entry.value;
          final icon = contactIcons[type] ?? Icons.contact_phone;

          List<Widget> actions = [];
          if (type == 'mobile' || type == 'phone') {
            actions.addAll([
              IconButton(
                icon: const Icon(Icons.call, color: Colors.black87),
                onPressed: () async {
                  final url = Uri.parse('tel:$value');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.message, color: Colors.black87),
                onPressed: () async {
                  final url = Uri.parse('sms:$value');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),
            ]);
          } else if (type == 'email') {
            actions.add(
              IconButton(
                icon: const Icon(Icons.email, color: Colors.black87),
                onPressed: () async {
                  final url = Uri.parse('mailto:$value');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),
            );
          } else if (type == 'website') {
            actions.add(
              IconButton(
                icon: const Icon(Icons.launch, color: Colors.black87),
                onPressed: () async {
                  final url = Uri.parse(value);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),
            );
          }

          return GestureDetector(
            onLongPress: () => _showDeleteDialog(type, value),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      Text(
                        contactTitles[type] ?? type,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(value),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _showDeleteDialog(type, value),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  void _showDeleteDialog(String type, String value) {
    Get.dialog(
      AlertDialog(
        title: const Text('연락처 삭제'),
        content: Text('이 연락처를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteContact(type);
              Get.back();
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
