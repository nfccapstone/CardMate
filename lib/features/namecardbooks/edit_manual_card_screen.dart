import 'package:cardmate/features/namecardbooks/manual_card_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditManualCardScreen extends StatefulWidget {
  final String cardId;
  final Map<String, dynamic> cardData;

  const EditManualCardScreen({
    super.key,
    required this.cardId,
    required this.cardData,
  });

  @override
  State<EditManualCardScreen> createState() => _EditManualCardScreenState();
}

class _EditManualCardScreenState extends State<EditManualCardScreen> {
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _contacts = List<Map<String, dynamic>>.from(widget.cardData['contacts'] ?? []);
  }

  Future<void> _saveCard() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('오류', '로그인이 필요합니다.');
        return;
      }

      final cardData = {
        'contacts': _contacts,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('make_book')
          .doc(widget.cardId)
          .update(cardData);

      // 명함첩으로 돌아가기
      Get.until((route) => route.isFirst);
      Get.snackbar('성공', '연락처가 수정되었습니다.');
    } catch (e) {
      Get.snackbar('오류', '연락처 수정 중 오류가 발생했습니다.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddContactDialog() {
    final typeController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('연락처 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '연락처 유형',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '전화번호', child: Text('전화번호')),
                DropdownMenuItem(value: '이메일', child: Text('이메일')),
                DropdownMenuItem(value: '주소', child: Text('주소')),
              ],
              onChanged: (value) {
                typeController.text = value ?? '';
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: '연락처',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (typeController.text.isNotEmpty && valueController.text.isNotEmpty) {
                setState(() {
                  _contacts.add({
                    'type': typeController.text,
                    'value': valueController.text,
                  });
                });
                Get.back();
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('연락처 관리'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 개인정보 표시 (읽기 전용)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '개인정보',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('이름', widget.cardData['name'] ?? ''),
                  const SizedBox(height: 8),
                  _buildInfoRow('직책', widget.cardData['position'] ?? ''),
                  const SizedBox(height: 8),
                  _buildInfoRow('부서', widget.cardData['department'] ?? ''),
                  const SizedBox(height: 8),
                  _buildInfoRow('회사', widget.cardData['company'] ?? ''),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '연락처',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddContactDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('연락처 추가'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      _getContactIcon(contact['type']),
                      color: Colors.black,
                    ),
                    title: Text(contact['value']),
                    subtitle: Text(contact['type']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _contacts.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      '저장',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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