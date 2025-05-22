import 'dart:ffi';

import 'package:cardmate/features/namecard/controllers/edit_card_controller.dart';
import 'package:cardmate/features/namecardbooks/card_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class NameCardListScreen extends StatelessWidget {
  const NameCardListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CardController cardController = Get.find<CardController>();
    final EditCardController editCardController =
        Get.find<EditCardController>();

    return Obx(() {
      if (cardController.cards.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                "저장된 명함이 없습니다",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        itemCount: cardController.cards.length,
        itemBuilder: (context, index) {
          final card = cardController.cards[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  if (card.webLink != null) {
                    if (int.tryParse(card.id) != null) {
                      Get.toNamed('edit-manual-card',
                          arguments: {'cardId': card.id});
                    } else {
                      final Uri url = Uri.parse(card.webLink!);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        Get.snackbar(
                          '오류',
                          '링크를 열 수 없습니다.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.black87,
                          colorText: Colors.white,
                        );
                      }
                    }
                  }
                },
                onLongPress: () {
                  Get.dialog(
                    Dialog(
                      backgroundColor: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.25),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '명함 삭제',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${card.name ?? '이름 없는 명함'}을(를) 삭제하시겠습니까?',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Get.back(),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('취소'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await cardController
                                            .deleteCard(card.id);
                                        Get.back();
                                        Get.snackbar(
                                          '성공',
                                          '명함이 삭제되었습니다.',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.black87,
                                          colorText: Colors.white,
                                        );
                                      } catch (e) {
                                        Get.back();
                                        Get.snackbar(
                                          '오류',
                                          '명함 삭제에 실패했습니다.',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.black87,
                                          colorText: Colors.white,
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text('삭제'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey[100],
                        backgroundImage: (card.profileUrl != null &&
                                card.profileUrl!.isNotEmpty)
                            ? NetworkImage(card.profileUrl!)
                            : null,
                        child: (card.profileUrl == null ||
                                card.profileUrl!.isEmpty)
                            ? const Icon(Icons.person,
                                color: Colors.grey, size: 32)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.name ?? '이름 없음',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (card.department != null && card.position != null)
                                  ? '${card.department}/${card.position}'
                                  : (card.department ?? card.position ?? ''),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              card.company ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
