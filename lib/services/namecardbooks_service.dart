import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cardmate/services/firebase/firebase_init.dart';

class HomeService {
  final FirebaseFirestore _firestore = FirebaseInit.instance.firestore;
  final FirebaseAuth _auth = FirebaseInit.instance.auth;

  Future<List<Map<String, dynamic>>> fetchNameCardList() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('namecard_list')
          .orderBy('updatedAt', descending: true) // 최신순 정렬
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('명함 목록 불러오기 오류: $e');
      return [];
    }
  }

  /// 📥 연락처 정보 불러오기 (users/{uid}/my_namecard/contact)
  Future<Map<String, String>?> fetchContactInfo() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_namecard')
          .doc('contact')
          .get();

      if (doc.exists && doc.data() != null) {
        return Map<String, String>.from(doc.data()!);
      }
    } catch (e) {
      print('연락처 불러오기 오류: $e');
    }

    return null;
  }

  /// ✏️ 기본 명함 정보 수정 (users/{uid})
  Future<bool> updateCardData(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      await _firestore.collection('users').doc(user.uid).update(data);
      return true;
    } catch (e) {
      print('명함 수정 오류: $e');
      return false;
    }
  }

  /// 🔎 명함 등록 여부 확인 (my_namecard/basic_info 문서 존재 여부)
  Future<bool> checkCardExists() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_namecard')
          .doc('basic_info')
          .get();
      return doc.exists;
    } catch (e) {
      print('명함 존재 여부 확인 실패: $e');
      return false;
    }
  }
}
