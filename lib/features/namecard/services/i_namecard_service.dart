import 'dart:io';

abstract class INameCardService {
  /// Firestore에 기본 정보 저장
  Future<void> saveBasicInfo(Map<String, dynamic> data);
  /// Firestore에서 기본 정보 불러오기
  Future<Map<String, dynamic>?> fetchBasicInfo();
  /// 공유된 명함 정보 불러오기
  Future<Map<String, dynamic>?> fetchSharedNameCard(String nameCardId);
  /// 웹 공유를 위한 명함 정보 불러오기
  Future<Map<String, dynamic>?> getCardForWeb(String cardId);
}
