import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cardmate/services/firebase/firebase_init.dart';

class ContactService {
  final _auth = FirebaseInit.instance.auth;
  final _firestore = FirebaseInit.instance.firestore;

  /// 연락처 저장: type은 'mobile', 'email' 등, value는 실제 입력값
  Future<void> saveContact(String type, String value) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('my_namecard')
          .doc('contacts');

      await docRef.set({type: value}, SetOptions(merge: true));
    } catch (e) {
      print('연락처 저장 오류: $e');
      rethrow;
    }
  }

  /// 연락처 불러오기: Map<String, String> 형태로 반환
  Future<Map<String, String>?> fetchContacts() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('my_namecard')
          .doc('contacts')
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
