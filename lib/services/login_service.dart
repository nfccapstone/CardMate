import 'package:firebase_auth/firebase_auth.dart';

class LoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signIn(String email, String password) async {
    try {
      // Firebase Authentication을 사용하여 이메일/비밀번호로 로그인
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
