import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cardmate/firebase/firebase_init.dart';
import 'i_contact_service.dart';

class ContactService implements IContactService {
  final _auth = FirebaseInit.instance.auth;
  final _firestore = FirebaseInit.instance.firestore;

  Future<String?> getCardId(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['cardId'] as String?;
  }

  @override
  Future<void> saveContact(String type, String value) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final cardId = await getCardId(uid);
    if (cardId == null) return;

    try {
      // card_contact 서브컬렉션에 연락처 정보 저장
      await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_contact')
          .doc('contacts')
          .set({
        type: value,
      }, SetOptions(merge: true));

      // card_data 서브컬렉션의 updatedAt 필드 업데이트
      await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_data')
          .doc('data')
          .set({
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('연락처 저장 오류: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, String>?> fetchContacts([String? _]) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final cardId = await getCardId(uid);
    if (cardId == null) return null;

    try {
      final doc = await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_contact')
          .doc('contacts')
          .get();

      if (doc.exists && doc.data() != null) {
        return Map<String, String>.from(doc.data()!);
      }
      return null;
    } catch (e) {
      print('연락처 불러오기 오류: $e');
      return null;
    }
  }

  @override
  Future<void> deleteContact(String type) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final cardId = await getCardId(uid);
    if (cardId == null) return;

    try {
      // card_contact 서브컬렉션에서 연락처 정보 삭제
      await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_contact')
          .doc('contacts')
          .update({
        type: FieldValue.delete(),
      });

      // card_data 서브컬렉션의 updatedAt 필드 업데이트
      await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_data')
          .doc('data')
          .set({
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('연락처 삭제 오류: $e');
      rethrow;
    }
  }
}
