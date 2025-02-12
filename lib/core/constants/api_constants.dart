import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      // Web 環境
      return 'http://localhost:3000/api';
    } else if (Platform.isAndroid) {
      // Android 模擬器環境
      return 'http://10.0.2.2:3000/api';
    } else if (Platform.isIOS) {
      // iOS 模擬器環境
      return 'http://localhost:3000/api';
    } else {
      // 其他環境（桌面等）
      return 'http://localhost:3000/api';
    }
  }

  // API 端點
  static const String chatEndpoint = '/chat';
  static const String chatListEndpoint = '/chat/list';
  static const String chatCurrentEndpoint = '/chat/current';
  static const String chatAllEndpoint = '/chat/all';

  // HTTP 標頭
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
}
