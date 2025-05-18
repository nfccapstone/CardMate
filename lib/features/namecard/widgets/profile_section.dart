// profile_section.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileSection extends StatelessWidget {
  final Map<String, dynamic> basicInfo;
  final bool readOnly;
  
  const ProfileSection({
    Key? key, 
    required this.basicInfo,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = basicInfo;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    Widget profileContent = Container(
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
    );

    return readOnly 
      ? profileContent
      : GestureDetector(
          onTap: () {
            Get.toNamed('/namecardInfo');
          },
          child: profileContent,
        );
  }
}
