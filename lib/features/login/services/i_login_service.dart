import 'package:firebase_auth/firebase_auth.dart';

abstract class ILoginService {
  Future<User?> signIn(String email, String password);
  Future<void> signOut();

  /// 구글 계정으로 로그인
  Future<User?> signInWithGoogle();
}
