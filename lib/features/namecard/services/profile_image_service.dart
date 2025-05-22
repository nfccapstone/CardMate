import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cardmate/firebase/firebase_init.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'i_profile_image_service.dart';

class ProfileImageService implements IProfileImageService {
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseInit.instance.auth;
  final _firestore = FirebaseInit.instance.firestore;
  
  // 메모리 캐시
  String? _cachedCardId;
  String? _cachedProfileUrl;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);
  
  // 이미지 최적화 설정
  static const _maxImageSize = 800; // 최대 이미지 크기
  static const _imageQuality = 85; // 이미지 품질 (0-100)

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

  // 이미지 최적화 메서드
  Future<Uint8List> _optimizeImage(File file) async {
    // 이미지 로드
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;

    // 이미지 리사이징
    var resizedImage = image;
    if (image.width > _maxImageSize || image.height > _maxImageSize) {
      resizedImage = img.copyResize(
        image,
        width: image.width > image.height ? _maxImageSize : null,
        height: image.height > image.width ? _maxImageSize : null,
      );
    }

    // JPEG로 인코딩 (압축)
    return Uint8List.fromList(img.encodeJpg(resizedImage, quality: _imageQuality));
  }

  // 디스크 캐시 관련 메서드
  Future<String> _getCachePath(String url) async {
    final cacheDir = await getTemporaryDirectory();
    final hash = sha256.convert(utf8.encode(url)).toString();
    return '${cacheDir.path}/profile_$hash.jpg';
  }

  Future<void> _saveToDiskCache(String url, Uint8List data) async {
    try {
      final path = await _getCachePath(url);
      final file = File(path);
      await file.writeAsBytes(data);
    } catch (e) {
      print('디스크 캐시 저장 오류: $e');
    }
  }

  Future<Uint8List?> _getFromDiskCache(String url) async {
    try {
      final path = await _getCachePath(url);
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    } catch (e) {
      print('디스크 캐시 읽기 오류: $e');
    }
    return null;
  }

  @override
  Future<String> uploadProfileImage(File file) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('사용자가 로그인되어 있지 않습니다.');
    
    final cardId = await getCardId(uid);
    if (cardId == null) throw Exception('cardId가 없습니다.');

    try {
      // 이미지 최적화
      final optimizedBytes = await _optimizeImage(file);
      
      // 이미지 업로드와 Firestore 업데이트를 병렬로 처리
      final ref = _storage.ref().child('cards/$cardId/images/profile.jpg');
      final uploadTask = ref.putData(optimizedBytes);
      
      // 업로드 완료 대기
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // 디스크 캐시에 저장
      await _saveToDiskCache(downloadUrl, optimizedBytes);

      // Firestore 업데이트와 캐시 업데이트를 병렬로 처리
      await Future.wait([
        _firestore.collection('cards').doc(cardId).update({
          'profileImageUrl': downloadUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }),
        _firestore.collection('cards').doc(cardId).collection('card_data').doc('data').set({
          'updatedAt': FieldValue.serverTimestamp(),
          'changeType': 'profile_image_updated',
          'changeDetail': '프로필 이미지가 변경되었습니다.',
        }, SetOptions(merge: true)),
      ]);

      // 메모리 캐시 업데이트
      _cachedProfileUrl = downloadUrl;
      _lastFetchTime = DateTime.now();

      return downloadUrl;
    } catch (e) {
      print('프로필 이미지 업로드 오류: $e');
      rethrow;
    }
  }

  @override
  Future<String?> getProfileImageUrl() async {
    // 메모리 캐시 확인
    if (_isCacheValid() && _cachedProfileUrl != null) {
      return _cachedProfileUrl;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    try {
      final cardId = await getCardId(uid);
      if (cardId == null) return null;

      final doc = await _firestore.collection('cards').doc(cardId).get();
      final url = doc.data()?['profileImageUrl'] as String?;
      
      if (url != null) {
        _cachedProfileUrl = url;
        _lastFetchTime = DateTime.now();
        
        // 디스크 캐시 확인 및 다운로드
        final cachedData = await _getFromDiskCache(url);
        if (cachedData == null) {
          // 캐시에 없으면 다운로드
          final ref = _storage.refFromURL(url);
          final data = await ref.getData();
          if (data != null) {
            await _saveToDiskCache(url, data);
          }
        }
      }
      
      return url;
    } catch (e) {
      print('프로필 이미지 URL 가져오기 오류: $e');
      return null;
    }
  }

  @override
  void clearCache() {
    _cachedCardId = null;
    _cachedProfileUrl = null;
    _lastFetchTime = null;
    _clearDiskCache();
  }

  Future<void> _clearDiskCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final files = await cacheDir.list().where((entity) => 
        entity.path.contains('profile_')).toList();
      
      for (var file in files) {
        await file.delete();
      }
    } catch (e) {
      print('디스크 캐시 삭제 오류: $e');
    }
  }
} 