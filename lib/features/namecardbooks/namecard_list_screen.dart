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

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        (card.profileUrl != null && card.profileUrl!.isNotEmpty)
                            ? NetworkImage(card.profileUrl!)
                            : null,
                    backgroundColor: Colors.grey[200],
                    child: (card.profileUrl == null || card.profileUrl!.isEmpty)
                        ? const Icon(Icons.person, color: Colors.grey, size: 32)
                        : null,
                  ),
                  title: Text(card.name ?? '이름 없음'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (card.department != null && card.position != null)
                            ? '${card.department}/${card.position}'
                            : (card.department ?? card.position ?? ''),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        card.company ?? '',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
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
                );
              },
            ));
      }),
    );
  }
}
