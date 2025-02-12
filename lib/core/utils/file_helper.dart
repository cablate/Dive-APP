import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class FileHelper {
  static Future<String> imageToBase64(XFile file) async {
    final bytes = await file.readAsBytes();
    final base64String = base64Encode(bytes);
    return 'data:image/${file.name.split('.').last};base64,$base64String';
  }

  static Future<Uint8List?> base64ToBytes(String base64String) async {
    try {
      final data = base64String.split(',')[1];
      return base64Decode(data);
    } catch (e) {
      return null;
    }
  }
}
