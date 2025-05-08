import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cardmate/firebase/firebase_init.dart';
import 'i_profile_image_service.dart';

class ProfileImageService implements IProfileImageService {
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseInit.instance.auth;
  final _firestore = FirebaseInit.instance.firestore;

  Future<String?> getCardId(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['cardId'] as String?;
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

      // Firestore에 profileImageUrl 저장
      await _firestore.collection('cards').doc(cardId).update({
        'profileImageUrl': downloadUrl,
      });

      return downloadUrl;
    } catch (e) {
      print('프로필 이미지 업로드 오류: $e');
      rethrow;
    }
  }
} 