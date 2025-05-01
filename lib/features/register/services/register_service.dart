import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cardmate/firebase/firebase_init.dart';
import 'i_register_service.dart';

class RegisterService implements IRegisterService {
  // FirebaseAuth와 Firestore 인스턴스를 FirebaseInit을 통해 가져옵니다.
  final FirebaseAuth _auth = FirebaseInit.instance.auth;
  final FirebaseFirestore _firestore = FirebaseInit.instance.firestore;

  @override
  Future<User?> signUp({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    String? position,
    String? company,
    String? department,
    String? profileImageUrl,
  }) async {
    try {
      // 1️⃣ Firebase Authentication으로 계정 생성
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
    
      // 2️⃣ Firestore에 추가 정보 저장
      if (user != null) {
        await _firestore.collection("users").doc(user.uid).set({
          'name': name,
          'position': position ?? '',
          'company': company ?? '',
          'department': department ?? '', //회사내 부서 또는 학교내 부서
          'profileImageUrl': profileImageUrl ?? '', // 프로필 이미지 URL
        });
        await _firestore.collection("users").doc(user.uid).collection("card_contact").add({
          'email': email,
          'phoneNumber': phoneNumber,
        });
      }

      return user;
    } catch (e) {
      print("회원가입 오류: $e");
      // 예외를 전파해서 컨트롤러에서 한 번에 처리할 수 있습니다.
      rethrow;
    }
  }
}
