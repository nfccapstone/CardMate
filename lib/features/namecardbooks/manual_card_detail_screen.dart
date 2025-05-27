import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cardmate/features/namecardbooks/edit_manual_card_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ManualCardDetailScreen extends StatefulWidget {
  final String cardId;
  final Map<String, dynamic> cardData;

  const ManualCardDetailScreen({
    super.key,
    required this.cardId,
    required this.cardData,
  });

  @override
  State<ManualCardDetailScreen> createState() => _ManualCardDetailScreenState();
}

class _ManualCardDetailScreenState extends State<ManualCardDetailScreen> {
  late Stream<DocumentSnapshot> _cardStream;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _cardStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('make_book')
          .doc(widget.cardId)
          .snapshots();
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('오류', '링크를 열 수 없습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'CardMate',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Get.to(() => EditManualCardScreen(
                cardId: widget.cardId,
                cardData: widget.cardData,
              ));
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _cardStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('오류가 발생했습니다.'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final cardData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 프로필 카드
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
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
                  child: _buildProfileSection(cardData),
                ),
                // 연락처 카드
                if ((cardData['contacts'] ?? []).isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
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
                    child: _buildContactsSection(cardData),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileSection(Map<String, dynamic> cardData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[800],
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardData['name'] ?? '이름 없음',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${cardData['department'] ?? ''} / ${cardData['position'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cardData['company'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsSection(Map<String, dynamic> cardData) {
    final contacts = List<Map<String, dynamic>>.from(cardData['contacts'] ?? []);
    
    if (contacts.isEmpty) {
      return const SizedBox.shrink();
    }

    // 연락처 타입별 순서 정의
    final typeOrder = {
      '전화번호': 0,
      '유선전화': 1,
      '이메일': 2,
      '홈페이지': 3,
      '주소': 4,
      '팩스': 5,
    };

    // 연락처를 순서대로 정렬
    contacts.sort((a, b) {
      final aOrder = typeOrder[a['type']] ?? 999;
      final bOrder = typeOrder[b['type']] ?? 999;
      return aOrder.compareTo(bOrder);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '연락처',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...contacts.map((contact) {
          final type = contact['type'];
          final value = contact['value'];
          IconData icon;
          VoidCallback? onTap;

          if (type == '전화번호' || type == '유선전화') {
            icon = Icons.phone;
            onTap = () => launchUrl(Uri.parse('tel:$value'));
          } else if (type == '이메일') {
            icon = Icons.email;
            onTap = () => launchUrl(Uri.parse('mailto:$value'));
          } else if (type == '홈페이지') {
            icon = Icons.language;
            onTap = () => launchUrl(Uri.parse(value));
          } else if (type == '주소') {
            icon = Icons.location_on;
            onTap = null;
          } else if (type == '팩스') {
            icon = Icons.fax;
            onTap = null;
          } else {
            icon = Icons.contact_phone;
            onTap = null;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.black87),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            value,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            type,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}