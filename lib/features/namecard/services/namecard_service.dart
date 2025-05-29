import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cardmate/firebase/firebase_init.dart';
import 'package:cardmate/features/namecard/services/i_namecard_service.dart';

class NameCardService implements INameCardService {
  final _auth = FirebaseInit.instance.auth;
  final _firestore = FirebaseInit.instance.firestore;
  final _storage = FirebaseStorage.instance;

  Future<String?> getCardId(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['cardId'] as String?;
  }

  @override
  Future<void> saveBasicInfo(Map<String, dynamic> data) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // cardId가 없으면 새로 생성
    String? cardId = await getCardId(uid);
    cardId ??= _firestore.collection('cards').doc().id;

    try {
      // users/{uid}에는 cardId만 저장
      await _firestore.collection('users').doc(uid).set({
        'cardId': cardId,
      }, SetOptions(merge: true));

      // cards/{cardId}에 명함 정보 저장
      final basicData = {
        'name': data['name'],
        'position': data['position'],
        'company': data['company'],
        'department': data['department'],
        'profileImageUrl': data['profileImageUrl'],
        'uid': uid,
      };
      await _firestore
          .collection('cards')
          .doc(cardId)
          .set(basicData, SetOptions(merge: true));

      // cards/{cardId}/card_data/data 문서에 updatedAt 저장
      await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_data')
          .doc('data')
          .set({
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('기본 정보 저장 오류: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchBasicInfo() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final cardId = await getCardId(uid);
    if (cardId == null) return null;

    try {
      final doc = await _firestore.collection('cards').doc(cardId).get();
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
    final cardId = await getCardId(uid);
    if (cardId == null) throw Exception('cardId가 없습니다.');

    try {
      final ref = _storage.ref().child('cards/$cardId/images/profile.jpg');
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      // cards/{cardId}에 프로필 이미지 URL 업데이트
      await _firestore.collection('cards').doc(cardId).update({
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
      final doc =
          await _firestore.collection('shared_namecards').doc(nameCardId).get();

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

  @override
  Future<Map<String, dynamic>?> getNameCardById(String cardId) async {
    try {
      final doc = await _firestore.collection('namecards').doc(cardId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting namecard: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> getCardForWeb(String cardId) async {
    try {
      // 기본 정보 가져오기
      final cardDoc = await _firestore.collection('cards').doc(cardId).get();
      if (!cardDoc.exists) return null;

      final cardData = cardDoc.data()!;
      
      // 연락처 정보 가져오기
      final contactsDoc = await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_contact')
          .doc('contacts')
          .get();
      
      if (contactsDoc.exists) {
        final contacts = contactsDoc.data()!;
        final Map<String, dynamic> orderedContacts = {};
        
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
          if (contacts.containsKey(type)) {
            orderedContacts[type] = contacts[type];
          }
        }

        cardData['contacts'] = orderedContacts;
      }

      // 블록 정보 가져오기
      final blocksSnapshot = await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_block')
          .orderBy('order', descending: false)
          .get();

      final blocks = blocksSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      cardData['blocks'] = blocks;

      return cardData;
    } catch (e) {
      print('웹용 명함 데이터 불러오기 오류: $e');
      return null;
    }
  }
}
