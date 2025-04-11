import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IHomeService {
  /// 현재 로그인한 사용자의 기본 명함 정보 불러오기 (users/{uid}/my_namecard/basic_info)
  Future<Map<String, dynamic>?> fetchCardData();
  
  /// 연락처 정보 불러오기 (users/{uid}/my_namecard/contact)
  Future<Map<String, String>?> fetchContactInfo();
  
  /// 기본 명함 정보 수정 (users/{uid})
  Future<bool> updateCardData(Map<String, dynamic> data);
  
  /// 명함 등록 여부 확인 (기본 정보 문서 존재 여부)
  Future<bool> checkCardExists();
}
