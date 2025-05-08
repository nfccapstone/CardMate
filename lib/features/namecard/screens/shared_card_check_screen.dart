import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SharedCardCheckScreen extends StatefulWidget {
  const SharedCardCheckScreen({Key? key}) : super(key: key);

  @override
  State<SharedCardCheckScreen> createState() => _SharedCardCheckScreenState();
}

class _SharedCardCheckScreenState extends State<SharedCardCheckScreen> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? cardData;
  String? error;

  Future<void> fetchSharedCard() async {
    setState(() {
      cardData = null;
      error = null;
    });
    final cardId = _controller.text.trim();
    if (cardId.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('shared_namecards')
          .doc(cardId)
          .get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          cardData = doc.data();
        });
      } else {
        setState(() {
          error = '해당 CardId의 공유 명함이 존재하지 않습니다.';
        });
      }
    } catch (e) {
      setState(() {
        error = '오류: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('공유 명함 확인')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'CardId 입력',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchSharedCard,
              child: const Text('공유 명함 불러오기'),
            ),
            const SizedBox(height: 24),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            if (cardData != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: cardData!.entries.map((entry) {
                      return Text('${entry.key}: ${entry.value}');
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 