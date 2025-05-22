import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cardmate/firebase/firebase_init.dart';
import 'package:image_picker/image_picker.dart';
import 'services/i_home_service.dart';

class HomeService implements IHomeService {
  final FirebaseFirestore _firestore = FirebaseInit.instance.firestore;
  final FirebaseAuth _auth = FirebaseInit.instance.auth;
  
  // 캐시 데이터
  Map<String, dynamic>? _cachedCardData;
  Map<String, String>? _cachedContactInfo;
  String? _cachedCardId;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  Future<String?> getCardId(String uid) async {
    if (_cachedCardId != null) return _cachedCardId;
    
    final doc = await _firestore.collection('users').doc(uid).get();
    _cachedCardId = doc.data()?['cardId'] as String?;
    return _cachedCardId;
  }

  bool _isCacheValid() {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  @override
  Future<Map<String, dynamic>?> fetchCardData() async {
    // 캐시가 유효하면 캐시된 데이터 반환
    if (_isCacheValid() && _cachedCardData != null) {
      return _cachedCardData;
    }

    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final cardId = await getCardId(user.uid);
      if (cardId == null) return null;

      // 기본 정보와 연락처 정보를 병렬로 가져오기
      final results = await Future.wait([
        _firestore.collection('cards').doc(cardId).get(),
        _firestore.collection('cards').doc(cardId).collection('card_contact').doc('contacts').get(),
      ]);

      final cardDoc = results[0];
      final contactDoc = results[1];

      if (cardDoc.exists && cardDoc.data() != null) {
        final data = cardDoc.data()!;
        data['cardId'] = cardId;

        // 연락처 정보가 있으면 추가
        if (contactDoc.exists && contactDoc.data() != null) {
          data['contact'] = contactDoc.data();
        }

        // 캐시 업데이트
        _cachedCardData = data;
        _lastFetchTime = DateTime.now();
        return data;
      }
      return null;
    } catch (e) {
      print('명함 정보 가져오기 오류: $e');
      return null;
    }
  }

  @override
  Future<Map<String, String>?> fetchContactInfo() async {
    // 캐시가 유효하면 캐시된 데이터 반환
    if (_isCacheValid() && _cachedContactInfo != null) {
      return _cachedContactInfo;
    }

    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final cardId = await getCardId(user.uid);
      if (cardId == null) return null;

      final doc = await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_contact')
          .doc('contacts')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = Map<String, String>.from(doc.data()!);
        _cachedContactInfo = data;
        _lastFetchTime = DateTime.now();
        return data;
      }
      return null;
    } catch (e) {
      print('연락처 불러오기 오류: $e');
      return null;
    }
  }

  @override
  Future<bool> updateCardData(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final cardId = await getCardId(user.uid);
      if (cardId == null) return false;

      // 데이터 업데이트
      await _firestore.collection('cards').doc(cardId).update(data);
      
      // 캐시 무효화
      _cachedCardData = null;
      _cachedContactInfo = null;
      _lastFetchTime = null;
      
      return true;
    } catch (e) {
      print('명함 수정 오류: $e');
      return false;
    }
  }

  @override
  Future<bool> checkCardExists() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final cardId = await getCardId(user.uid);
      if (cardId == null) return false;

      final doc = await _firestore.collection('cards').doc(cardId).get();
      return doc.exists;
    } catch (e) {
      print('명함 존재 여부 확인 실패: $e');
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchCardBlocks() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final cardId = await getCardId(user.uid);
      if (cardId == null) return [];

      final snapshot = await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_block')
          .orderBy('order', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('명함 블록 불러오기 오류: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchCardStyle() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final cardId = await getCardId(user.uid);
      if (cardId == null) return null;

      final doc = await _firestore
          .collection('cards')
          .doc(cardId)
          .collection('card_style')
          .doc('style')
          .get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('명함 스타일 불러오기 오류: $e');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    // 캐시 초기화
    _cachedCardData = null;
    _cachedContactInfo = null;
    _cachedCardId = null;
    _lastFetchTime = null;
    
    await _auth.signOut();
  }
}
