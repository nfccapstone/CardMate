import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cardmate/features/namecardbooks/edit_manual_card_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('명함 상세'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildInfoSection('이름', cardData['name'] ?? ''),
                _buildInfoSection('직책', cardData['position'] ?? ''),
                _buildInfoSection('부서', cardData['department'] ?? ''),
                _buildInfoSection('회사', cardData['company'] ?? ''),
                const SizedBox(height: 32),
                const Text(
                  '연락처',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildContactsList(cardData),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList(Map<String, dynamic> cardData) {
    final contacts = List<Map<String, dynamic>>.from(cardData['contacts'] ?? []);
    
    if (contacts.isEmpty) {
      return const Center(
        child: Text(
          '등록된 연락처가 없습니다',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              _getContactIcon(contact['type']),
              color: Colors.black,
            ),
            title: Text(contact['value']),
            subtitle: Text(contact['type']),
          ),
        );
      },
    );
  }

  IconData _getContactIcon(String type) {
    switch (type.toLowerCase()) {
      case '전화번호':
        return Icons.phone;
      case '이메일':
        return Icons.email;
      case '주소':
        return Icons.location_on;
      default:
        return Icons.contact_phone;
    }
  }
}