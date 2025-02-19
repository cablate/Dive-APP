import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../models/tool.dart';
import '../models/tool_config.dart';

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

  Future<List<ToolConfig>> getToolConfigs() async {
    try {
      final response = await _dio.get('/config/mcpserver');
      if (response.data['success']) {
        final configData = response.data['config']['mcpServers'] as Map<String, dynamic>;
        return configData.entries
            .map((entry) => ToolConfig.fromJson(entry))
            .toList();
      }
      throw Exception('獲取工具配置失敗: 請求未成功');
    } on DioException catch (e) {
      throw Exception('獲取工具配置失敗: ${e.message}');
    } catch (e) {
      throw Exception('獲取工具配置失敗: $e');
    }
  }

  Future<void> updateToolConfig(String toolName, ToolConfig config) async {
    try {
      final currentResponse = await _dio.get('/config/mcpserver');
      if (!currentResponse.data['success']) {
        throw Exception('獲取當前配置失敗');
      }

      final currentConfig = currentResponse.data['config'];
      final mcpServers = Map<String, dynamic>.from(currentConfig['mcpServers']);
      
      // 更新特定工具的配置
      mcpServers[toolName] = config.toJson();

      // 發送更新請求
      await _dio.post(
        '/config/mcpserver',
        data: {
          'mcpServers': mcpServers,
        },
      );
    } on DioException catch (e) {
      throw Exception('更新工具配置失敗: ${e.message}');
    } catch (e) {
      throw Exception('更新工具配置失敗: $e');
    }
  }

  Future<void> deleteToolConfig(String toolName) async {
    try {
      final currentResponse = await _dio.get('/config/mcpserver');
      if (!currentResponse.data['success']) {
        throw Exception('獲取當前配置失敗');
      }

      final currentConfig = currentResponse.data['config'];
      final mcpServers = Map<String, dynamic>.from(currentConfig['mcpServers']);
      
      // 刪除特定工具的配置
      mcpServers.remove(toolName);

      // 發送更新請求
      await _dio.put(
        '/config/mcpserver',
        data: {
          'mcpServers': mcpServers,
        },
      );
    } on DioException catch (e) {
      throw Exception('刪除工具配置失敗: ${e.message}');
    } catch (e) {
      throw Exception('刪除工具配置失敗: $e');
    }
  }
}
