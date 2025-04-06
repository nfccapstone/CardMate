import 'package:cardmate/screens/namecardbooks/card_controller.dart';
import 'package:cardmate/screens/namecardbooks/edit_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// CardController
import 'package:cardmate/screens/namecardbooks/card_model.dart'; // CardModel

class EditOtherCardScreen extends StatelessWidget {
  final CardModel card;
  const EditOtherCardScreen({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final cardController = Get.put(CardController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('디지털 명함 편집', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Obx(() {
        if (cardController.cards.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final currentCard = cardController.cards.firstWhere(
          (c) => c.id == card.id,
          orElse: () => card,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildNameCardPreview(currentCard),
              const SizedBox(height: 20),
              _buildAddButton('+ 연락처 추가'),
              const Divider(height: 40, color: Colors.white24),
              _buildAddButton('+ 블록 추가'),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildNameCardPreview(CardModel card) {
    return GestureDetector(
      onTap: () async {
        final result = await Get.to(EditCardScreen2(card: card));
        if (result == true) {
          Get.find<CardController>().fetchCards(); // reload
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green[700],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.name,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              '${card.department} / ${card.position}',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              card.company,
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
      ),
    );
  }

  Widget _buildAddButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}
