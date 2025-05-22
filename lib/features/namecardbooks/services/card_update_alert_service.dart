import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/card_update_alert.dart';

class CardUpdateAlertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CardUpdateAlert>> fetchChangedCards(String myUid) async {
    final myCards = await _firestore
        .collection('users')
        .doc(myUid)
        .collection('card_book')
        .get();

    // 병렬로 모든 카드의 알림 체크
    final futures = myCards.docs.map((doc) async {
      final cardId = doc.id;
      final lastChecked = doc.data().containsKey('lastChecked') ? doc['lastChecked'] : null;
      // card_data/data 문서에서 updatedAt 읽기
      final cardDataDocFuture = _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_data')
          .doc('data')
          .get();
      // cards/{cardId} 문서에서 name, profileImageUrl 읽기
      final cardDocFuture = _firestore.collection('cards').doc(cardId).get();
      final results = await Future.wait([cardDataDocFuture, cardDocFuture]);
      final cardDataDoc = results[0] as DocumentSnapshot;
      final cardDoc = results[1] as DocumentSnapshot;
      final updatedAt = cardDataDoc['updatedAt'];
      if (updatedAt != null && (lastChecked == null || lastChecked.toDate().isBefore(updatedAt.toDate()))) {
        return CardUpdateAlert(
          cardId: cardId,
          cardOwnerName: cardDoc['name'],
          cardOwnerProfileUrl: cardDoc['profileImageUrl'],
          updatedAt: updatedAt.toDate(),
        );
      }
      return null;
    }).toList();

    final results = await Future.wait(futures);
    // null이 아닌 것만 반환
    return results.whereType<CardUpdateAlert>().toList();
  }

  Future<void> markAsChecked(String myUid, String cardId) async {
    await _firestore
        .collection('users')
        .doc(myUid)
        .collection('card_book')
        .doc(cardId)
        .set({'lastChecked': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }
} 