import 'package:cardmate/firebase/firebase_init.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'i_edit_card_service.dart';

class EditCardService implements IEditCardService {
  final _auth = FirebaseInit.instance.auth;
  final _firestore = FirebaseInit.instance.firestore;
  final _storage = FirebaseInit.instance.storage;
  final String cardId = "1"; // 예시 카드 ID, 실제로는 Firebase에서 가져와야 함
  // final String cardId = FirebaseInit.instance.getCardId(_auth.currentUser!.uid) ?? '';

  @override
  Future<Map<String, dynamic>?> fetchBasicInfo() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    try {
      final doc = await _firestore.collection('cards').doc(cardId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('명함 정보 불러오기 오류: $e');
      return null;
    }
  }

  @override
  Future<bool> saveBasicInfo(Map<String, dynamic> data) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    try {
      // 기존 name 값 불러오기
      final userDoc = await _firestore.collection('cards').doc(cardId).get();
      String? originalName = userDoc.data()?['name'];
      // name 필드는 기존 값으로 고정
      final saveData = Map<String, dynamic>.from(data);
      if (originalName != null) {
        saveData['name'] = originalName;
      }
      // users/{uid}에 저장
      await _firestore
          .collection('cards')
          .doc(cardId)
          .set(saveData, SetOptions(merge: true));

      // users/{uid}/card_data/data 문서에 createdAt, updatedAt 저장
      final cardDataRef = _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_data')
          .doc('data');
      final cardDataDoc = await cardDataRef.get();
      if (!cardDataDoc.exists) {
        await cardDataRef.set({
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await cardDataRef.update({
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      return true;
    } catch (e) {
      print('명함 정보 저장 오류: $e');
      return false;
    }
  }

  @override
  Future<void> addBlock(Map<String, dynamic> blockData) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_block')
          .add(blockData);
    } catch (e) {
      print('블록 저장 오류: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchBlocks() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];
    try {
      final snapshot = await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_block')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // 문서 ID도 함께 저장
        return data;
      }).toList();
    } catch (e) {
      print('블록 불러오기 오류: $e');
      return [];
    }
  }

  @override
  Future<String?> uploadImage(Uint8List imageBytes, String fileName) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    try {
      // 이미지 파일 경로 설정 (users/{uid}/images/{fileName})
      final ref = _storage.ref().child('users/$uid/images/$fileName');

      // 이미지 업로드
      final uploadTask = await ref.putData(imageBytes);

      // 업로드된 이미지의 다운로드 URL 반환
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('이미지 업로드 오류: $e');
      return null;
    }
  }

  @override
  Future<void> deleteBlock(String blockId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_block')
          .doc(blockId)
          .delete();
    } catch (e) {
      print('블록 삭제 오류: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, String>?> fetchContactsFromSubcollection() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    try {
      final doc = await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_contact')
          .doc('contacts')
          .get();
      if (doc.exists && doc.data() != null) {
        return Map<String, String>.from(doc.data()!);
      }
      return null;
    } catch (e) {
      print('연락처 서브컬렉션 불러오기 오류: $e');
      return null;
    }
  }
}
