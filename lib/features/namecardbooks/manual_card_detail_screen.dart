import 'package:cardmate/features/namecardbooks/edit_manual_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManualCardDetailScreen extends StatelessWidget {
  final String cardId;
  final Map<String, dynamic> cardData;

  const ManualCardDetailScreen({
    super.key,
    required this.cardId,
    required this.cardData,
  });

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
                cardId: cardId,
                cardData: cardData,
              ));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
            _buildContactsList(),
          ],
        ),
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

  Widget _buildContactsList() {
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