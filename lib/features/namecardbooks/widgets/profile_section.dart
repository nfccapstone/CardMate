import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/features/namecardbooks/card_model.dart';

class ProfileSection extends StatelessWidget {
  final CardModel basicInfo;

  const ProfileSection({Key? key, required this.basicInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            basicInfo.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${basicInfo.department} / ${basicInfo.position}',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            basicInfo.company,
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
    );
  }
}
