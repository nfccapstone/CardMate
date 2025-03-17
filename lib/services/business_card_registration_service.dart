import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessCardRegistrationService {
  String? getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Map<String, String> parseNfcDate(String nfcData) {
    Map<String, String> parsedData = {};

    List<String> lines = nfcData.split("\n");
    for (String line in lines) {
      if (line.contains(": ")) {
        List<String> parts = line.split(": ");
        String key = parts[0].trim();
        String value = parts.length > 1 ? parts[1].trim() : "";
        parsedData[key] = value;
      }
    }
    return parsedData;
  }

  Future<void> saveNfcDataToFirebase(String nfcData) async {
    String? userId = getCurrentUserId();
    if (userId == null) {
      print("User ID is null");
      return;
    }

    Map<String, String> parsedData = parseNfcDate(nfcData);
    print(parsedData);
    print(userId);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('businessCards')
          .add({
        'name': parsedData['이름'],
        'phone': parsedData['전화번호'],
        'email': parsedData['이메일'],
        'company': parsedData['소속'],
        'position': parsedData['직함'],
        'address': parsedData['주소'],
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error saving data to Firebase: $e");
    }
  }
}
