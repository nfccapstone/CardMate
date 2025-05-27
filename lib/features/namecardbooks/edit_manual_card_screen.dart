
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cardmate/features/namecardbooks/manual_card_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('make_book')
          .doc(widget.cardId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['contacts'] != null) {
          setState(() {
            _contacts = List<Map<String, dynamic>>.from(data['contacts']);
          });
        }
      }
    } catch (e) {
      print('연락처 로드 실패: $e');
    }
  }

  Future<void> _saveCard() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('오류', '로그인이 필요합니다.');
        return;
      }

      final updatedCardData = {
        ...widget.cardData,
        'contacts': _contacts,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('make_book')
          .doc(widget.cardId)
          .update(updatedCardData);

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
    String selectedType = '전화번호';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: const Text(
          '연락처 추가',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: '연락처 유형',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: '전화번호', child: Text('전화번호')),
                    DropdownMenuItem(value: '유선전화', child: Text('유선전화')),
                    DropdownMenuItem(value: '이메일', child: Text('이메일')),
                    DropdownMenuItem(value: '홈페이지', child: Text('홈페이지')),
                    DropdownMenuItem(value: '주소', child: Text('주소')),
                    DropdownMenuItem(value: '팩스', child: Text('팩스')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      selectedType = value;
                      typeController.text = value;
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: valueController,
                  decoration: InputDecoration(
                    labelText: '연락처',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '추가',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        actionsPadding: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '연락처 관리',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
              child: _buildProfileSection(),
            ),
            const SizedBox(height: 12),
            // 연락처 카드
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
              child: _buildContactsSection(),
            ),
            const SizedBox(height: 12),
            // 연락처 추가 버튼
            GestureDetector(
              onTap: _showAddContactDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '+ 연락처 추가',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 저장 버튼
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
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
                  widget.cardData['name'] ?? '이름 없음',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.cardData['department'] ?? ''} / ${widget.cardData['position'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.cardData['company'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsSection() {
    if (_contacts.isEmpty) {
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
    _contacts.sort((a, b) {
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
        ..._contacts.map((contact) {
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
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _contacts.remove(contact);
                        });
                      },
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

