import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cardmate/firebase/firebase_init.dart';
import 'package:image_picker/image_picker.dart';
import 'services/i_home_service.dart';

class HomeService implements IHomeService {
  final FirebaseFirestore _firestore = FirebaseInit.instance.firestore;
  final FirebaseAuth _auth = FirebaseInit.instance.auth;
  final String cardId = "1"; // 예시 카드 ID, 실제로는 Firebase에서 가져와야 함
  //final String cardId = FirebaseInit.instance.getCardId(_auth.currentUser!.uid) ?? '';

  @override
  Future<Map<String, dynamic>?> fetchCardData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('cards').doc(cardId).get();
      return doc.data();
    } catch (e) {
      print('명함 정보 가져오기 오류: $e');
      return null;
    }
  }

  @override
  Future<Map<String, String>?> fetchContactInfo() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists && doc.data() != null) {
        return Map<String, String>.from(doc.data()!);
      }
    } catch (e) {
      print('연락처 불러오기 오류: $e');
    }
    return null;
  }

  @override
  Future<bool> updateCardData(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      await _firestore.collection('cards').doc(cardId).update(data);
      return true;
    } catch (e) {
      print('명함 수정 오류: $e');
      return false;
    }
  }

  @override
  Future<bool> checkCardExists() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore.collection('cards').doc(cardId).get();
      return doc.exists;
    } catch (e) {
      print('명함 존재 여부 확인 실패: $e');
      return false;
    }
  }
}
