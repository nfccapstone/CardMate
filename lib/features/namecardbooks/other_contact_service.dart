import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cardmate/firebase/firebase_init.dart';
import 'package:cardmate/features/namecardbooks/i_other_contact_service.dart';

class OtherContactService implements IOtherContactService {
  final _auth = FirebaseInit.instance.auth;
  final _firestore = FirebaseInit.instance.firestore;

  @override
  Future<void> saveContact(String cardId, String type, String value) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('card_concatct')
          .doc(cardId); // 연락처를 한 문서에 저장
      await docRef.set({type: value}, SetOptions(merge: true));
    } catch (e) {
      print('연락처 저장 오류: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, String>?> fetchContacts(String cardId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('card_contact')
          .doc(cardId)
          .get();
      if (doc.exists && doc.data() != null) {
        return Map<String, String>.from(doc.data()!);
      }
    } catch (e) {
      print('연락처 불러오기 오류: $e');
    }
    return null;
  }
}
