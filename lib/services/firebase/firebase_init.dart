import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseInit {
  static final FirebaseInit _instance = FirebaseInit._internal();
  late FirebaseFirestore firestore;
  late FirebaseAuth auth;

  static FirebaseInit get instance => _instance;

  factory FirebaseInit() {
    return _instance;
  }

  FirebaseInit._internal();

  Future<void> initializeFirebase() async {
    // 1) Firebase 초기화
    await Firebase.initializeApp();
    
    // 2) Cloud Firestore 인스턴스
    firestore = FirebaseFirestore.instance; // 또는 instanceFor(app: Firebase.app())
    
    // 3) Firebase Auth 인스턴스
    auth = FirebaseAuth.instance;
  }
}
