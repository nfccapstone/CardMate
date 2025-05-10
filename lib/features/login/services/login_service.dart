import 'package:firebase_auth/firebase_auth.dart';
import 'package:cardmate/firebase/firebase_init.dart';
import 'i_login_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';

class LoginService implements ILoginService {
  final FirebaseAuth _auth = FirebaseInit.instance.auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } catch (e) {
      print("로그인 오류: $e");
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut(); // Google 로그아웃도 함께 처리
  }

  @override
  Future<User?> signInWithGoogle() async {
    try {
      // 기존 세션이 있을 경우 로그아웃 처리
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // 로그인 취소

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print("구글 로그인 오류: $e");
      rethrow;
    }
  }
}
