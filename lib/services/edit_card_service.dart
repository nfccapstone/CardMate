import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cardmate/services/firebase/firebase_init.dart';

class EditCardService {
  final _auth = FirebaseInit.instance.auth;
  final _firestore = FirebaseInit.instance.firestore;

  Future<Map<String, dynamic>?> fetchBasicInfo() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('my_namecard')
          .doc('basic_info')
          .get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('명함 정보 불러오기 오류: $e');
      return null;
    }
  }

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
    print('연락처 저장 실패: $e');
    rethrow;
  }
}

}
