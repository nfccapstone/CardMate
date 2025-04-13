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
          .collection('my_namecard')
          .doc('basic_info')
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
      await _firestore.collection('users')
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
