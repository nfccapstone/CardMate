import 'package:cardmate/firebase/firebase_init.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'i_edit_card_service.dart';

class EditCardService implements IEditCardService {
  final _auth = FirebaseInit.instance.auth;
  final _firestore = FirebaseInit.instance.firestore;
  final _storage = FirebaseInit.instance.storage;

  Future<String?> getCardId(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['cardId'] as String?;
  }

  @override
  Future<Map<String, dynamic>?> fetchBasicInfo() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final cardId = await getCardId(uid);
    if (cardId == null) return null;
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
    final cardId = await getCardId(uid);
    if (cardId == null) return false;
    try {
      // 기존 name 값 불러오기
      final cardDoc = await _firestore.collection('cards').doc(cardId).get();
      String? originalName = cardDoc.data()?['name'];
      // name 필드는 기존 값으로 고정
      final saveData = Map<String, dynamic>.from(data);
      if (originalName != null) {
        saveData['name'] = originalName;
      }
      // cards/{cardId}에 저장
      await _firestore
          .collection('cards')
          .doc(cardId)
          .set(saveData, SetOptions(merge: true));

      // cards/{cardId}/card_data/data 문서에 createdAt, updatedAt 저장
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
    final cardId = await getCardId(uid);
    if (cardId == null) return;
    try {
      // 새로운 Map을 생성하여 원본 데이터 보존
      final dataToSave = Map<String, dynamic>.from(blockData);
      dataToSave['createdAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_block')
          .add(dataToSave);

      // card_data 서브컬렉션의 updatedAt 필드 업데이트
      await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_data')
          .doc('data')
          .set({
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('블록 저장 오류: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchBlocks() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];
    final cardId = await getCardId(uid);
    if (cardId == null) return [];
    try {
      // 먼저 createdAt으로 정렬하여 가져옴
      final snapshot = await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_block')
          .orderBy('createdAt', descending: false)
          .get();

      final blocks = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // order 필드가 없는 블록이 있다면 초기화
      bool needsUpdate = false;
      for (int i = 0; i < blocks.length; i++) {
        if (!blocks[i].containsKey('order')) {
          needsUpdate = true;
          await _firestore
              .collection('cards')
              .doc(cardId)
              .collection('card_block')
              .doc(blocks[i]['id'])
              .update({'order': i});
          blocks[i]['order'] = i;
        }
      }

      // order 필드로 다시 정렬
      blocks.sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));
      return blocks;
    } catch (e) {
      print('블록 불러오기 오류: $e');
      return [];
    }
  }

  @override
  Future<String?> uploadImage(Uint8List imageBytes, String fileName) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final cardId = await getCardId(uid);
    if (cardId == null) return null;

    try {
      // 이미지 파일 경로 설정 (cards/{cardId}/images/{fileName})
      final ref = _storage.ref().child('cards/$cardId/images/$fileName');

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
    final cardId = await getCardId(uid);
    if (cardId == null) return;
    try {
      await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_block')
          .doc(blockId)
          .delete();

      // card_data 서브컬렉션의 updatedAt 필드 업데이트
      await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_data')
          .doc('data')
          .set({
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('블록 삭제 오류: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, String>?> fetchContactsFromSubcollection() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final cardId = await getCardId(uid);
    if (cardId == null) return null;
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

  // 타인의 명함 정보 불러오기
  Future<Map<String, dynamic>?> fetchBasicInfoByCardId(String cardId) async {
    try {
      final doc = await _firestore.collection('cards').doc(cardId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('타인 명함 정보 불러오기 오류: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchBlocksByCardId(String cardId) async {
    try {
      // 먼저 createdAt으로 정렬하여 가져옴
      final snapshot = await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_block')
          .orderBy('createdAt', descending: false)
          .get();

      final blocks = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // order 필드가 없는 블록이 있다면 초기화
      bool needsUpdate = false;
      for (int i = 0; i < blocks.length; i++) {
        if (!blocks[i].containsKey('order')) {
          needsUpdate = true;
          await _firestore
              .collection('cards')
              .doc(cardId)
              .collection('card_block')
              .doc(blocks[i]['id'])
              .update({'order': i});
          blocks[i]['order'] = i;
        }
      }

      // order 필드로 다시 정렬
      blocks.sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));
      return blocks;
    } catch (e) {
      print('타인 블록 불러오기 오류: $e');
      return [];
    }
  }

  Future<Map<String, String>?> fetchContactsByCardId(String cardId) async {
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
      print('타인 연락처 불러오기 오류: $e');
      return null;
    }
  }

  @override
  Future<void> updateBlockOrder(List<Map<String, dynamic>> blocks) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final cardId = await getCardId(uid);
    if (cardId == null) return;

    try {
      // 각 블록의 순서를 업데이트
      for (int i = 0; i < blocks.length; i++) {
        final block = blocks[i];
        await _firestore
            .collection('cards')
            .doc(cardId)
            .collection('card_block')
            .doc(block['id'])
            .update({
          'order': i,
        });
      }

      // card_data 서브컬렉션의 updatedAt 필드 업데이트
      await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_data')
          .doc('data')
          .set({
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('블록 순서 업데이트 오류: $e');
      rethrow;
    }
  }

  @override
  Future<void> addLink(Map<String, String> linkData) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final cardId = await getCardId(uid);
    if (cardId == null) return;

    try {
      final dataToSave = {
        'title': linkData['title'],
        'url': linkData['url'],
        'platform': linkData['platform'] ?? 'direct',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_link')
          .add(dataToSave);

      // card_data 서브컬렉션의 updatedAt 필드 업데이트
      await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_data')
          .doc('data')
          .set({
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('링크 저장 오류: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, String>>> fetchLinks() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];
    final cardId = await getCardId(uid);
    if (cardId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_link')
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] as String,
          'url': data['url'] as String,
          'platform': data['platform'] as String? ?? 'direct',
        };
      }).toList();
    } catch (e) {
      print('링크 불러오기 오류: $e');
      return [];
    }
  }

  Future<List<Map<String, String>>> fetchLinksByCardId(String cardId) async {
    try {
      final snapshot = await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_link')
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] as String,
          'url': data['url'] as String,
          'platform': data['platform'] as String? ?? 'direct',
        };
      }).toList();
    } catch (e) {
      print('타인 링크 불러오기 오류: $e');
      return [];
    }
  }

  @override
  Future<void> deleteLink(String linkId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final cardId = await getCardId(uid);
    if (cardId == null) return;

    try {
      await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_link')
          .doc(linkId)
          .delete();

      // card_data 서브컬렉션의 updatedAt 필드 업데이트
      await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_data')
          .doc('data')
          .set({
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('링크 삭제 오류: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateBlock(String blockId, Map<String, dynamic> blockData) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final cardId = await getCardId(uid);
    if (cardId == null) return;

    try {
      // 새로운 Map을 생성하여 원본 데이터 보존
      final dataToSave = Map<String, dynamic>.from(blockData);
      dataToSave['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_block')
          .doc(blockId)
          .update(dataToSave);

      // card_data 서브컬렉션의 updatedAt 필드 업데이트
      await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_data')
          .doc('data')
          .set({
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('블록 수정 오류: $e');
      rethrow;
    }
  }
}
