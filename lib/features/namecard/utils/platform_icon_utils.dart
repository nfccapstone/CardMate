import 'package:flutter/material.dart';

class PlatformIconUtils {
  static Widget getPlatformIcon(String platform, {double size = 24}) {
    try {
      switch (platform.toLowerCase()) {
        case 'instagram':
          return Image.asset(
            'assets/icons/instagram.png',
            width: size,
            height: size,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Instagram 이미지 로드 실패: $error');
              return Icon(Icons.camera_alt, color: Colors.deepPurple, size: size);
            },
          );
        case 'github':
          return Image.asset(
            'assets/icons/github.png',
            width: size,
            height: size,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('GitHub 이미지 로드 실패: $error');
              return Icon(Icons.code, color: Colors.deepPurple, size: size);
            },
          );
        default:
          return Icon(Icons.link, color: Colors.deepPurple, size: size);
      }
    } catch (e) {
      debugPrint('아이콘 로드 중 오류 발생: $e');
      return Icon(Icons.error, color: Colors.red, size: size);
    }
  }
} 