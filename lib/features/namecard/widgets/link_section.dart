import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/features/namecard/controllers/edit_card_controller.dart';
import 'package:cardmate/features/namecard/utils/platform_icon_utils.dart';

class LinkSection extends StatelessWidget {
  const LinkSection({Key? key}) : super(key: key);

  Widget _getPlatformIcon(String platform) {
    return PlatformIconUtils.getPlatformIcon(platform);
  }

  @override
  Widget build(BuildContext context) {
    final editController = Get.find<EditCardController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '링크',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (editController.links.isEmpty) {
            return const Center(
              child: Text(
                '추가된 링크가 없습니다.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            );
          }
          
          return Column(
            children: editController.links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
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
                  children: [
                    _getPlatformIcon(link['platform'] ?? 'direct'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        link['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        final linkId = link['id'];
                        if (linkId != null) {
                          editController.deleteLink(linkId);
                        }
                      },
                    ),
                  ],
                ),
              ),
            )).toList(),
          );
        }),
      ],
    );
  }
} 