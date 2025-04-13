import 'package:firebase_auth/firebase_auth.dart';

abstract class IRegisterService {
  /// 회원가입을 수행합니다.
  /// 성공 시 [User] 객체를 반환하며, 실패하면 예외를 전파합니다.
  Future<User?> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? position,
    String? company,
  });
}
