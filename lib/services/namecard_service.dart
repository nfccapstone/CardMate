import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:cardmate/services/firebase/firebase_init.dart';

class NameCardService {
  final _auth = FirebaseInit.instance.auth;
  final _firestore = FirebaseInit.instance.firestore;

  Future<bool> saveBasicInfo(Map<String, dynamic> data) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('my_namecard')
          .doc('basic_info')
          .set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('기본 정보 저장 오류: $e');
      return false;
    }
  }
}
