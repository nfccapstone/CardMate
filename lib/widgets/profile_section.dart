// profile_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/getX/controllers/edit_card_controller.dart';

class ProfileSection extends StatelessWidget {
  final EditCardController controller;
  const ProfileSection({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = controller.basicInfo;
    return GestureDetector(
      onTap: () async {
        final result = await Get.toNamed('/namecardInfo');
        if (result == true) {
          controller.loadNameCardData();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black,
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
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${data['department'] ?? ''} / ${data['position'] ?? ''}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              data['company'] ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
