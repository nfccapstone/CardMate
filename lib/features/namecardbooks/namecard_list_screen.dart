import 'package:cardmate/features/namecardbooks/card_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class NameCardListScreen extends StatelessWidget {
  const NameCardListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CardController cardController = Get.find<CardController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (cardController.cards.isEmpty) {
          return const Center(child: Text("저장된 명함이 없습니다."));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ListView.builder(
            itemCount: cardController.cards.length,
            itemBuilder: (context, index) {
              final card = cardController.cards[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    if (card.webLink != null) {
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
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: card.profileUrl != null
                              ? NetworkImage(card.profileUrl!)
                              : null,
                          backgroundColor: Colors.grey[200],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            card.name ?? '이름 없음',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
