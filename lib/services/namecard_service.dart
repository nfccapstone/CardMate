import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // ✅ 추가
import 'package:cardmate/services/firebase/firebase_init.dart';

class NameCardService {
  final _auth = FirebaseInit.instance.auth;
  final _firestore = FirebaseInit.instance.firestore;
  final _storage = FirebaseStorage.instance;

  /// 🔹 프로필 사진 Firebase Storage에 업로드 후 다운로드 URL 반환
  Future<String> uploadProfileImage(File imageFile) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return '';

    try {
      final ref = _storage.ref().child('profile_images/$uid.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL(); // ✅ 다운로드 URL 반환
    } catch (e) {
      print('이미지 업로드 오류: $e');
      return '';
    }
  }

  /// 🔹 기본 정보 Firestore에 저장
  Future<bool> saveBasicInfo(Map<String, dynamic> data) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('my_namecard')
          .doc('basic_info')
          .set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('기본 정보 저장 오류: $e');
      return false;
    }
  }
  /// 🔹 Firestore에서 명함 기본 정보 불러오기 
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
    return doc.data();
  } catch (e) {
    print('기본 정보 불러오기 오류: $e');
    return null;
  }
}
}