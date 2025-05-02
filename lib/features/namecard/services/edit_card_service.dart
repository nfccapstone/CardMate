import 'package:cardmate/firebase/firebase_init.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'i_edit_card_service.dart';

class EditCardService implements IEditCardService {
  final _auth = FirebaseInit.instance.auth;
  final _firestore = FirebaseInit.instance.firestore;

  @override
  Future<Map<String, dynamic>?> fetchBasicInfo() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('명함 정보 불러오기 오류: $e');
      return null;
    }
  }

  @override
  Future<bool> saveBasicInfo(Map<String, dynamic> data) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    try {
      // 기존 name 값 불러오기
      final userDoc = await _firestore.collection('users').doc(uid).get();
      String? originalName = userDoc.data()?['name'];
      // name 필드는 기존 값으로 고정
      final saveData = Map<String, dynamic>.from(data);
      if (originalName != null) {
        saveData['name'] = originalName;
      }
      // users/{uid}에 저장
      await _firestore.collection('users').doc(uid).set(saveData, SetOptions(merge: true));

      // users/{uid}/card_data/data 문서에 createdAt, updatedAt 저장
      final cardDataRef = _firestore.collection('users').doc(uid).collection('card_data').doc('data');
      final cardDataDoc = await cardDataRef.get();
      if (!cardDataDoc.exists) {
        await cardDataRef.set({
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await cardDataRef.update({
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      return true;
    } catch (e) {
      print('명함 정보 저장 오류: $e');
      return false;
    }
  }
}
