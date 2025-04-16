import 'package:cardmate/features/namecardbooks/card_controller.dart';
import 'package:cardmate/features/namecardbooks/edit_othercard_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NameCardListScreen extends StatelessWidget {
  const NameCardListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CardController cardController = Get.put(CardController());

    return Scaffold(
      body: Obx(() {
        if (cardController.cards.isEmpty) {
          return const Center(child: Text("저장된 명함이 없습니다."));
        }

        return ListView.builder(
          itemCount: cardController.cards.length,
          itemBuilder: (context, index) {
            final card = cardController.cards[index];

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(card.profileUrl ?? ''),
                backgroundColor: Colors.grey[200],
              ),
              title: Text(card.name ?? '이름 없음'),
              onTap: () {
                Get.to(() => EditOtherCardScreen(card: card));
              },
            );
          },
        );
      }),
    );
  }
}
