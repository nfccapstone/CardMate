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
      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('card_contact')
          .doc('contacts');
      await docRef.set({type: value}, SetOptions(merge: true));

      final nameCardId = await getNameCardId(uid); // await로 값을 가져와야 함

      if (nameCardId != null) {
        final ref = _firestore
            .collection('shared_namecards')
            .doc(nameCardId)
            .collection('namecard')
            .doc('contacts');

        await ref.set({type: value}, SetOptions(merge: true));
      }
    } catch (e) {
      print('연락처 저장 오류: $e');
      rethrow;
    }
  }

  Future<String?> getNameCardId(uid) async {
    try {
      final data = await _firestore
          .collection('users')
          .doc(uid)
          .collection('my_namecard')
          .doc('basic_info')
          .get();

      String nameCardId = data['nameCardId'];
      return nameCardId;
    } catch (e) {
      print('데이터 접근 불가');
    }
  }

  @override
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
