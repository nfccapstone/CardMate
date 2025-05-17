import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/features/namecard/controllers/edit_card_controller.dart';

class LinkSection extends StatelessWidget {
  const LinkSection({Key? key}) : super(key: key);

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
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, color: Colors.deepPurple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            link['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            link['url'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new, color: Colors.deepPurple),
                      onPressed: () {
                        final url = link['url'] ?? '';
                        if (url.isNotEmpty) {
                          // TODO: URL 실행 로직 구현
                          print('Open URL: $url');
                        }
                      },
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