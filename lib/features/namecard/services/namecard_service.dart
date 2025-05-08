import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cardmate/firebase/firebase_init.dart';
import 'package:cardmate/features/namecard/services/i_namecard_service.dart';

class NameCardService implements INameCardService {
  final _auth = FirebaseInit.instance.auth;
  final _firestore = FirebaseInit.instance.firestore;
  final _storage = FirebaseStorage.instance;

  @override
  Future<void> saveBasicInfo(Map<String, dynamic> data) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      // 트랜잭션을 사용하여 데이터 일관성 보장
      await _firestore.runTransaction((transaction) async {
        // 사용자 문서 업데이트 (기본 필드만 저장)
        final basicData = {
          'name': data['name'],
          'position': data['position'],
          'company': data['company'],
          'department': data['department'],
          'profileImageUrl': data['profileImageUrl'],
          'uid': uid,
        };
        
        transaction.set(
          _firestore.collection('users').doc(uid),
          basicData,
          SetOptions(merge: true),
        );

        // card_data 서브컬렉션 업데이트
        transaction.set(
          _firestore.collection('users').doc(uid).collection('card_data').doc('data'),
          {
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      });
    } catch (e) {
      print('기본 정보 저장 오류: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchBasicInfo() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      return doc.data();
    } catch (e) {
      print('기본 정보 불러오기 오류: $e');
      return null;
    }
  }

  @override
  Future<String> uploadProfileImage(File file) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

    try {
      final ref = _storage.ref().child('users/$uid/images/profile.jpg');
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      
      // 프로필 이미지 URL 업데이트
      await _firestore.collection('users').doc(uid).update({
        'profileImageUrl': downloadUrl,
      });
      
      return downloadUrl;
    } catch (e) {
      print('프로필 이미지 업로드 오류: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchSharedNameCard(String nameCardId) async {
    try {
      final doc = await _firestore
          .collection('shared_namecards')
          .doc(nameCardId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      // 연락처 정보 가져오기
      final contactsDoc = await _firestore
          .collection('shared_namecards')
          .doc(nameCardId)
          .collection('card_contact')
          .doc('contacts')
          .get();

      if (contactsDoc.exists) {
        data['contacts'] = contactsDoc.data();
      }

      return data;
    } catch (e) {
      print('공유 명함 불러오기 오류: $e');
      return null;
    }
  }
}
