import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cardmate/firebase/firebase_init.dart';
import 'i_profile_image_service.dart';

class ProfileImageService implements IProfileImageService {
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseInit.instance.auth;

  @override
  Future<String> uploadProfileImage(File file) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

    try {
      final ref = _storage.ref().child('profile_images/$uid.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print('프로필 이미지 업로드 오류: $e');
      rethrow;
    }
  }
} 