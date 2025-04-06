//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:cardmate/services/firebase/firebase_init.dart';

class EditCardService {
  final _auth = FirebaseInit.instance.auth;
  final _firestore = FirebaseInit.instance.firestore;

  /// Firestore에서 명함 기본 정보 불러오기
  Future<Map<String, dynamic>?> fetchBasicInfo() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('namecard_list')
          .doc('basic_info')
          .get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('명함 정보 불러오기 오류: $e');
      return null;
    }
  }

  /// Firestore에 명함 기본 정보 저장
  Future<bool> saveBasicInfo(Map<String, dynamic> data) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('my_namecard')
          .doc('basic_info')
          .set(data);
      return true;
    } catch (e) {
      print('명함 정보 저장 오류: $e');
      return false;
    }
  }
}
