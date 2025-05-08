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
      print('회원가입 시작: $email');

      // 1️⃣ Firebase Authentication으로 계정 생성
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      print('Firebase Auth 계정 생성 성공: ${user?.uid}');

      // 2️⃣ Firestore에 추가 정보 저장
      if (user != null) {
        // 사용자 기본 정보 저장
        await _firestore.collection("users").doc(user.uid).set({
          'name': name,
          'position': position ?? '',
          'company': company ?? '',
          'department': department ?? '',
          'profileImageUrl': profileImageUrl ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('사용자 기본 정보 저장 성공');

        // 연락처 정보 저장
        await _firestore
            .collection("users")
            .doc(user.uid)
            .collection("card_contact")
            .doc("contacts")
            .set({
          'email': email,
          'phoneNumber': phoneNumber,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print('연락처 정보 저장 성공');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth 오류: ${e.code} - ${e.message}');
      rethrow;
    } on FirebaseException catch (e) {
      print('Firebase 오류: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('회원가입 중 예기치 못한 오류: $e');
      rethrow;
    }
  }
}
