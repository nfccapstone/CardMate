import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cardmate/firebase/firebase_init.dart'; // FirebaseInit 가져오기

class RegisterService {
  final FirebaseAuth _auth = FirebaseInit.instance.auth; // ✅ FirebaseInit에서 FirebaseAuth 가져오기
  final FirebaseFirestore _firestore = FirebaseInit.instance.firestore; // ✅ Firestore 가져오기

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
