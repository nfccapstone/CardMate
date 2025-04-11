import 'package:firebase_auth/firebase_auth.dart';

abstract class ILoginService {
  /// 이메일과 비밀번호로 로그인을 시도하며, 성공 시 User 객체를 반환합니다.
  Future<User?> signIn(String email, String password);
  
  /// 로그아웃을 수행합니다.
  Future<void> signOut();
}
