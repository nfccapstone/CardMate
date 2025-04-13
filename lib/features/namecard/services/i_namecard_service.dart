import 'dart:io';

abstract class INameCardService {
  /// 프로필 이미지 업로드 후 다운로드 URL 반환
  Future<String> uploadProfileImage(File imageFile);
  /// Firestore에 기본 정보 저장
  Future<bool> saveBasicInfo(Map<String, dynamic> data);
  /// Firestore에서 기본 정보 불러오기
  Future<Map<String, dynamic>?> fetchBasicInfo();
}
