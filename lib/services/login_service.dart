import 'package:firebase_auth/firebase_auth.dart';
import 'package:cardmate/services/firebase/firebase_init.dart'; // FirebaseInit import

class LoginService {
  final FirebaseAuth _auth = FirebaseInit.instance.auth; // ✅ FirebaseInit에서 FirebaseAuth 가져오기

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("로그인 오류: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
