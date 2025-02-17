import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/api_constants.dart';
import '../../domain/entities/chat_message.dart';
import '../models/chat_history_model.dart';
import '../models/chat_message_model.dart';

class ChatApiProvider {
  final Dio _dio;

  ChatApiProvider() : _dio = Dio() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  Stream<List<ChatMessageModel>> sendMessageStream({
    required String message,
    List<String>? files,
    String? chatId,
  }) async* {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('message', message));
      if (chatId != null && chatId.isNotEmpty) {
        formData.fields.add(MapEntry('chatId', chatId));
      }

      if (files != null) {
        for (final file in files) {
          if (kIsWeb) {
            // Web 平台：預期 files 包含 base64 字串
            formData.files.add(MapEntry(
              'images',
              MultipartFile.fromBytes(
                base64Decode(file.split(',').last),
                filename: 'image.jpg',
              ),
            ));
          } else {
            // 原生平台：預期 files 包含檔案路徑
            formData.files.add(MapEntry(
              'images',
              await MultipartFile.fromFile(file),
            ));
          }
        }
      }

      // 立即創建一個空的 AI 回應訊息
      final String currentMessageId = DateTime.now().toString();
      List<ToolCall>? currentToolCalls;
      ToolResult? currentToolResult;

      final initialMessage = ChatMessageModel(
        id: currentMessageId,
        messageId: currentMessageId,
        chatId: currentMessageId,
        content: '',
        role: 'assistant',
        type: 'text',
      );

      // 發送初始訊息
      yield [initialMessage];

      // 使用非阻塞方式發送請求
      final request = _dio.post(
        '/chat',
        data: formData,
        options: Options(
          responseType: ResponseType.stream,
        ),
      );

      // 立即開始監聽回應
      final response = await request;
      final stream = response.data.stream as Stream<List<int>>;
      final decoder = const Utf8Decoder();
      String buffer = '';
      String currentText = '';

      await for (final chunk in stream) {
        final String chunkText = decoder.convert(chunk);
        buffer += chunkText;

        while (buffer.contains('\n')) {
          final index = buffer.indexOf('\n');
          final line = buffer.substring(0, index);
          buffer = buffer.substring(index + 1);

          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') {
              if (currentText.isNotEmpty) {
                yield [
                  ChatMessageModel(
                    id: currentMessageId,
                    messageId: currentMessageId,
                    chatId: currentMessageId,
                    content: currentText,
                    role: 'assistant',
                    type: 'text',
                    toolCalls: currentToolCalls,
                    toolResult: currentToolResult,
                  )
                ];
              }
              break;
            }

            try {
              final jsonData = json.decode(data);
              if (jsonData['error'] != null) {
                throw Exception(jsonData['error']);
              }

              final message = json.decode(jsonData['message']);
              switch (message['type']) {
                case 'chat_info':
                  final content = message['content'];
                  yield [
                    ChatMessageModel(
                      id: content['id'],
                      messageId: content['id'],
                      chatId: content['id'],
                      content: '',
                      role: 'assistant',
                      type: 'chat_info',
                      title: content['title'],
                    )
                  ];
                  break;

                case 'text':
                  currentText += message['content'];
                  yield [
                    ChatMessageModel(
                      id: currentMessageId,
                      messageId: currentMessageId,
                      chatId: currentMessageId,
                      content: currentText,
                      role: 'assistant',
                      type: 'text',
                      toolCalls: currentToolCalls,
                      toolResult: currentToolResult,
                    )
                  ];
                  break;

                case 'tool_calls':
                  currentToolCalls = (message['content'] as List)
                      .map((e) => ToolCall(
                            name: e['name'] as String,
                            arguments:
                                Map<String, dynamic>.from(e['arguments']),
                          ))
                      .toList();

                  yield [
                    ChatMessageModel(
                      id: currentMessageId,
                      messageId: currentMessageId,
                      chatId: currentMessageId,
                      content: currentText,
                      role: 'assistant',
                      type: 'tool_calls',
                      toolCalls: currentToolCalls,
                      toolResult: currentToolResult,
                    )
                  ];
                  break;

                case 'tool_result':
                  currentToolResult = ToolResult(
                    name: message['content']['name'] as String,
                    result: message['content']['result'],
                  );

                  yield [
                    ChatMessageModel(
                      id: currentMessageId,
                      messageId: currentMessageId,
                      chatId: currentMessageId,
                      content: currentText,
                      role: 'assistant',
                      type: 'tool_result',
                      toolCalls: currentToolCalls,
                      toolResult: currentToolResult,
                    )
                  ];
                  break;

                case 'error':
                  yield [
                    ChatMessageModel(
                      id: currentMessageId,
                      messageId: currentMessageId,
                      chatId: currentMessageId,
                      content: message['content'],
                      role: 'assistant',
                      type: 'error',
                      toolCalls: currentToolCalls,
                      toolResult: currentToolResult,
                    )
                  ];
                  break;
              }
            } catch (e) {
              print('解析 SSE 資料失敗: $e');
            }
          }
        }
      }
    } catch (e) {
      throw Exception('發送訊息失敗: $e');
    }
  }

  Future<List<ChatMessageModel>> loadChat(String? chatId) async {
    try {
      final response = await _dio.get('/chat/${chatId ?? 'new'}');
      final resData = response.data['data'];
      final List<dynamic> data = resData['messages'];
      print('載入對話: $data');
      return data.map((json) => ChatMessageModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('載入對話失敗: $e');
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await _dio.delete('/chat/$chatId');
    } catch (e) {
      throw Exception('刪除對話失敗: $e');
    }
  }

  Future<List<ChatHistoryModel>> getChatHistory() async {
    try {
      final response = await _dio.get('/chat/list');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => ChatHistoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('載入歷史對話失敗: $e');
    }
  }

  Future<void> updateChatTitle(String chatId, String title) async {
    try {
      await _dio.patch('/chat/$chatId', data: {'title': title});
    } catch (e) {
      throw Exception('更新對話標題失敗: $e');
    }
  }

  Future<void> deleteAllChats() async {
    try {
      await _dio.delete('/chat/all');
    } catch (e) {
      throw Exception('刪除所有對話失敗: $e');
    }
  }

  // Future<ChatHistoryModel?> getCurrentChat() async {
  //   try {
  //     final response = await _dio.get('/chat/current');
  //     if (response.data == null) return null;
  //     return ChatHistoryModel.fromJson(response.data['chat']);
  //   } catch (e) {
  //     throw Exception('獲取當前對話失敗: $e');
  //   }
  // }
}
