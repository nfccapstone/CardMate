import 'package:firebase_auth/firebase_auth.dart';
import 'package:cardmate/firebase/firebase_init.dart';
import 'i_login_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginService implements ILoginService {
  final FirebaseAuth _auth = FirebaseInit.instance.auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseInit.instance.firestore;

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

      // 구글 로그인 성공 후 사용자 정보 확인
      if (userCredential.user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          // 새로운 사용자인 경우 CardId 화면으로 이동
          Get.offAllNamed('/cardId', arguments: {'userId': userCredential.user!.uid});
        } else {
          // 기존 사용자인 경우 홈 화면으로 이동
          Get.offAllNamed('/home');
        }
      }

      return userCredential.user;
    } catch (e) {
      print("구글 로그인 오류: $e");
      rethrow;
    }
  }
}
