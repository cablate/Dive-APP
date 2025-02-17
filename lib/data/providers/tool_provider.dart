import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../models/tool.dart';

class ToolProvider {
  final Dio _dio;

  ToolProvider() : _dio = Dio() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  Future<List<Tool>> getTools() async {
    try {
      final response = await _dio.get('/tools');
      if (response.data['success']) {
        final List<dynamic> toolsData = response.data['tools'];
        return toolsData.map((json) => Tool.fromJson(json)).toList();
      }
      throw Exception('獲取工具列表失敗: 請求未成功');
    } on DioException catch (e) {
      throw Exception('獲取工具列表失敗: ${e.message}');
    } catch (e) {
      throw Exception('獲取工具列表失敗: $e');
    }
  }

  Future<void> toggleTool(String toolName, bool enabled) async {
    try {
      await _dio.patch(
        '/api/tools/$toolName',
        data: {'enabled': enabled},
      );
    } on DioException catch (e) {
      throw Exception('切換工具狀態失敗: ${e.message}');
    } catch (e) {
      throw Exception('切換工具狀態失敗: $e');
    }
  }

  Future<Tool> getToolDetail(String toolName) async {
    try {
      final response = await _dio.get('/api/tools/$toolName');
      if (response.data['success']) {
        return Tool.fromJson(response.data['tool']);
      }
      throw Exception('獲取工具詳情失敗: 請求未成功');
    } on DioException catch (e) {
      throw Exception('獲取工具詳情失敗: ${e.message}');
    } catch (e) {
      throw Exception('獲取工具詳情失敗: $e');
    }
  }
}
