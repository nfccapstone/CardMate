import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cardmate/firebase/firebase_init.dart';
import 'i_contact_service.dart';

class ContactService implements IContactService {
  final _auth = FirebaseInit.instance.auth;
  final _firestore = FirebaseInit.instance.firestore;

  @override
  Future<void> saveContact(String type, String value) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      // 트랜잭션을 사용하여 데이터 일관성 보장
      await _firestore.runTransaction((transaction) async {
        // 사용자 문서의 연락처 정보 업데이트
        transaction.set(
          _firestore.collection('users').doc(uid),
          {'contact.$type': value},
          SetOptions(merge: true),
        );

        // 공유 명함의 연락처 정보 업데이트
        final nameCardId = await getNameCardId(uid);
        if (nameCardId != null) {
          transaction.set(
            _firestore.collection('shared_namecards').doc(nameCardId),
            {'contact.$type': value},
            SetOptions(merge: true),
          );
        }
      });
    } catch (e) {
      print('연락처 저장 오류: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, String>?> fetchContacts([String? _]) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    // card_contact/contacts 문서에서 읽기
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('card_contact')
        .doc('contacts')
        .get();

    if (doc.exists && doc.data() != null) {
      return Map<String, String>.from(doc.data()!);
    }
    return null;
  }

  @override
  Future<void> deleteContact(String type) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.runTransaction((transaction) async {
        // 사용자 문서에서 연락처 정보 삭제
        transaction.update(
          _firestore.collection('users').doc(uid),
          {'contact.$type': FieldValue.delete()},
        );

        // 공유 명함에서 연락처 정보 삭제
        final nameCardId = await getNameCardId(uid);
        if (nameCardId != null) {
          transaction.update(
            _firestore.collection('shared_namecards').doc(nameCardId),
            {'contact.$type': FieldValue.delete()},
          );
        }
      });
    } catch (e) {
      print('연락처 삭제 오류: $e');
      rethrow;
    }
  }

  Future<String?> getNameCardId(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      return doc.data()?['nameCardId'] as String?;
    } catch (e) {
      print('nameCardId 조회 오류: $e');
      return null;
    }
  }
}
