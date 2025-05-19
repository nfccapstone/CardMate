import 'package:firebase_auth/firebase_auth.dart';
import 'package:cardmate/firebase/firebase_init.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoreService {
  final FirebaseAuth _auth = FirebaseInit.instance.auth;

  Future<void> logout() async {
    // SharedPreferences에서 자동 로그인 정보 삭제
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');

    // Firebase 로그아웃
    await _auth.signOut();
  }
} 