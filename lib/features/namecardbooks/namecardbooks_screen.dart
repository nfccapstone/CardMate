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
    final CardController cardController = Get.put(CardController());
    final TextEditingController _searchController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 검색창
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  //const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: const InputDecoration(
                        hintText: '이름이나 회사명으로 검색',
                        hintStyle: TextStyle(color: Colors.grey),
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
                    icon: const Icon(Icons.search, color: Colors.grey),
                    onPressed: () {
                      _searchController.text.trim().isEmpty
                          ? cardController.fetchNameCards()
                          : cardController
                              .searchCard(_searchController.text.trim());
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 추가 버튼
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                _showAddCardOptions(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCardOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '다른 사람 명함 추가하기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              _buildOptionButton(
                context,
                Icons.nfc,
                'NFC 명함 태그',
                () => Get.toNamed('/add-card-nfc'),
              ),
              const SizedBox(height: 12),
              _buildOptionButton(
                context,
                Icons.qr_code_scanner,
                'QR 코드 찍기',
                () => Get.toNamed('/qr-scan'),
              ),
              const SizedBox(height: 12),
              _buildOptionButton(
                context,
                Icons.edit,
                '아이디로 명함 등록',
                () => Get.toNamed('/add-card-id'),
              ),
            ],
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
