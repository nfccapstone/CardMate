import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseInit {
  static final FirebaseInit _instance = FirebaseInit._internal();
  late FirebaseFirestore firestore;
  late FirebaseAuth auth;

  // Singleton 패턴으로 인스턴스 관리
  static FirebaseInit get instance => _instance;

  factory FirebaseInit() {
    return _instance;
  }

  FirebaseInit._internal();

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
    firestore = FirebaseFirestore.instance;
    auth = FirebaseAuth.instance;
  }
}
