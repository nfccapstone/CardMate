import 'package:cardmate/features/namecardbooks/add_card_byId_screen.dart';
import 'package:cardmate/features/namecardbooks/add_card_byNFC_screen.dart';
import 'package:cardmate/features/namecardbooks/card_controller.dart';
import 'package:cardmate/features/namecardbooks/qr_scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NamecardbooksScreen extends StatelessWidget {
  const NamecardbooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final CardController cardController = Get.find<CardController>();
    final CardController cardController = Get.put(CardController());
    final TextEditingController _searchController = TextEditingController();

    return Row(
      children: [
        Expanded(
          flex: 8,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white30),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: '이름이나 회사명으로 검색',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      value.isEmpty
                          ? cardController.fetchNameCards()
                          : cardController.searchCard(value);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    print("검색 버튼 눌러짐");
                    _searchController.text.trim().isEmpty
                        ? cardController.fetchNameCards()
                        : cardController
                            .searchCard(_searchController.text.trim());
                  },
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 0, 0, 0),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                _showAddCardOptions(context);
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showAddCardOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: false,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.40,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '다른 사람 명함 추가하기',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildOptionButton(context, Icons.nfc, 'NFC 명함 태그', () {
                  Get.toNamed('/add-card-nfc');
                }),
                const SizedBox(height: 12),
                _buildOptionButton(context, Icons.qr_code_scanner, 'QR 코드 찍기', () {
                  Get.toNamed('/qr-scan');
                }),
                const SizedBox(height: 12),
                _buildOptionButton(context, Icons.edit, '아이디로 명함 등록', () {
                  Get.toNamed('/add-card-id');
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 12),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
