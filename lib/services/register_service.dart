import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? position,
    String? company,
  }) async {
    try {
      // 1️⃣ Firebase Authentication을 사용하여 계정 생성
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      // 2️⃣ Firestore에 추가 정보 저장
      if (user != null) {
        await _firestore.collection("users").doc(user.uid).set({
          'name': name,
          'email': email,
          'phone': phone,
          'position': position ?? '',
          'company': company ?? '',
          'createdAt': FieldValue.serverTimestamp(), // 계정 생성 시간 저장
        });
      }

      return user;
    } catch (e) {
      print("회원가입 오류: $e");
      return null;
    }
  }
}
