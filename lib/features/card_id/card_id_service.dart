import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'i_card_id_service.dart';

class CardIdService implements ICardIdService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Random _random = Random();
  final String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  @override
  bool isValidCardIdFormat(String cardId) {
    // 16자리 영어 대문자와 숫자 조합 검증
    final RegExp regex = RegExp(r'^[A-Z0-9]{16}$');
    return regex.hasMatch(cardId);
  }

  String _generateRandomCardId() {
    return List.generate(16, (index) => _chars[_random.nextInt(_chars.length)])
        .join();
  }

  Future<bool> _checkCardIdExists(String cardId) async {
    try {
      final doc = await _firestore.collection('cards').doc(cardId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkCardIdInUse(String cardId) async {
    try {
      final doc = await _firestore.collection('cards').doc(cardId).get();
      if (!doc.exists) return false;

      final data = doc.data();
      return data?['userId'] != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String> generateUniqueCardId() async {
    String cardId;
    bool isUnique = false;
    int attempts = 0;
    const maxAttempts = 10;

    do {
      cardId = _generateRandomCardId();
      final exists = await _checkCardIdExists(cardId);
      final inUse = await _checkCardIdInUse(cardId);
      isUnique = !exists && !inUse;
      attempts++;

      if (attempts >= maxAttempts) {
        throw Exception('카드 ID 생성 시도 횟수를 초과했습니다.');
      }
    } while (!isUnique);

    return cardId;
  }

  @override
  Future<bool> validateCardId(String cardId) async {
    try {
      if (!isValidCardIdFormat(cardId)) {
        return false;
      }

      final exists = await _checkCardIdExists(cardId);
      if (!exists) {
        await _firestore.collection('cards').doc(cardId).set(
            {'createdAt': FieldValue.serverTimestamp(), 'status': 'available'});
        return true;
      }

      final inUse = await _checkCardIdInUse(cardId);
      if (inUse) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> linkCardIdToUser(String userId, String cardId) async {
    try {
      if (!isValidCardIdFormat(cardId)) {
        return false;
      }

      await _firestore.runTransaction((transaction) async {
        final cardDoc =
            await transaction.get(_firestore.collection('cards').doc(cardId));

        if (!cardDoc.exists) {
          throw Exception('카드가 존재하지 않습니다.');
        }

        final cardData = cardDoc.data();
        if (cardData?['userId'] != null) {
          throw Exception('이미 사용 중인 카드입니다.');
        }

        transaction.update(
          _firestore.collection('cards').doc(cardId),
          {'userId': userId, 'linkedAt': FieldValue.serverTimestamp()},
        );

        // 사용자 문서에 카드 ID 추가
        transaction.update(
          _firestore.collection('users').doc(userId),
          {'cardId': cardId, 'updatedAt': FieldValue.serverTimestamp()},
        );
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}
