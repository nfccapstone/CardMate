import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cardmate/firebase/firebase_init.dart';
import 'package:image_picker/image_picker.dart';
import 'services/i_home_service.dart';

class HomeService implements IHomeService {
  final FirebaseFirestore _firestore = FirebaseInit.instance.firestore;
  final FirebaseAuth _auth = FirebaseInit.instance.auth;

  Future<String?> getCardId(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['cardId'] as String?;
  }

  @override
  Future<Map<String, dynamic>?> fetchCardData() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      final cardId = await getCardId(user.uid);
      if (cardId == null) return null;
      final doc = await _firestore.collection('cards').doc(cardId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['cardId'] = cardId;
        return data;
      }
      return null;
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
      final cardId = await getCardId(user.uid);
      if (cardId == null) return null;
      final doc = await _firestore.collection('cards').doc(cardId).collection('card_contact').doc('contacts').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final Map<String, String> result = {};
        
        // 고정된 순서 정의
        final orderedTypes = [
          'mobile',    // 휴대전화
          'phone',     // 유선전화
          'email',     // 이메일
          'address',   // 주소
          'fax',       // 팩스
        ];

        // 고정된 순서대로 연락처 추가
        for (var type in orderedTypes) {
          if (data.containsKey(type)) {
            result[type] = data[type] as String;
          }
        }

        return result;
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
      final cardId = await getCardId(user.uid);
      if (cardId == null) return false;
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
      final cardId = await getCardId(user.uid);
      if (cardId == null) return false;
      final doc = await _firestore.collection('cards').doc(cardId).get();
      return doc.exists;
    } catch (e) {
      print('명함 존재 여부 확인 실패: $e');
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchCardBlocks() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    try {
      final cardId = await getCardId(user.uid);
      if (cardId == null) return [];
      final snapshot = await _firestore.collection('cards').doc(cardId).collection('card_block').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('명함 블록 불러오기 오류: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchCardStyle() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      final cardId = await getCardId(user.uid);
      if (cardId == null) return null;
      final doc = await _firestore.collection('cards').doc(cardId).collection('card_style').doc('style').get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('명함 스타일 불러오기 오류: $e');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }
}
