import 'package:firebase_auth/firebase_auth.dart';
import 'package:cardmate/firebase/firebase_init.dart';
import 'i_login_service.dart';

class LoginService implements ILoginService {
  // FirebaseAuth는 FirebaseInit에서 가져옵니다.
  final FirebaseAuth _auth = FirebaseInit.instance.auth;

  @override
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      // 에러 발생 시 로그를 남기고 예외를 전파하여 컨트롤러에서 처리하도록 합니다.
      print("로그인 오류: $e");
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
