import 'dart:io';

abstract class IProfileImageService {
  /// 프로필 이미지 업로드 후 다운로드 URL 반환
  Future<String> uploadProfileImage(File file);
} 