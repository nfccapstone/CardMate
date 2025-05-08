import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IHomeService {
  /// 현재 로그인한 사용자의 기본 명함 정보 불러오기 (users/{uid})
  Future<Map<String, dynamic>?> fetchCardData();
  
  /// 연락처 정보 불러오기 (users/{uid}/card_contact/contacts)
  Future<Map<String, String>?> fetchContactInfo();
  
  /// 기본 명함 정보 수정 (users/{uid})
  Future<bool> updateCardData(Map<String, dynamic> data);
  
  /// 명함 등록 여부 확인 (기본 정보 문서 존재 여부)
  Future<bool> checkCardExists();

  /// 명함 블록 정보 불러오기 (users/{uid}/card_block)
  Future<List<Map<String, dynamic>>> fetchCardBlocks();

  /// 명함 스타일 정보 불러오기 (users/{uid}/card_style/style)
  Future<Map<String, dynamic>?> fetchCardStyle();
}
