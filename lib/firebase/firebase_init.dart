import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseInit {
  static final FirebaseInit _instance = FirebaseInit._internal();
  late FirebaseFirestore firestore;
  late FirebaseAuth auth;
  late FirebaseStorage storage;

  static FirebaseInit get instance => _instance;

  factory FirebaseInit() {
    return _instance;
  }

  Future<String?> getCardId(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        print("카드ID: ${userDoc.get('cardID')}");
        return userDoc.get('cardID');
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching card ID: $e');
      return null;
    }
  }

  FirebaseInit._internal();

  Future<void> initializeFirebase() async {
    // 1) Firebase 초기화
    await Firebase.initializeApp();

    // 2) Cloud Firestore 인스턴스
    firestore =
        FirebaseFirestore.instance; // 또는 instanceFor(app: Firebase.app())

    // 3) Firebase Auth 인스턴스
    auth = FirebaseAuth.instance;

    // 4) Firebase Storage 인스턴스
    storage = FirebaseStorage.instance;
  }
}
