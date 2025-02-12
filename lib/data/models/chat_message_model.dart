import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.messageId,
    required super.chatId,
    required super.content,
    required super.role,
    super.files,
    super.type = 'text',
    super.toolCalls,
    super.toolResult,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'].toString(),
      messageId: json['messageId']?.toString() ?? json['id'].toString(),
      chatId: json['chatId'],
      content: json['content'] as String,
      role: json['role'] as String,
      files: (json['files'] as List?)?.cast<String>(),
      type: json['type'] as String? ?? 'text',
      toolCalls: (json['tool_calls'] as List?)?.map((e) {
        return ToolCall(
          name: e['name'] as String,
          arguments: e['arguments'] as Map<String, dynamic>,
        );
      }).toList(),
      toolResult: json['tool_result'] == null
          ? null
          : ToolResult(
              name: json['tool_result']['name'] as String,
              result: json['tool_result']['result'],
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messageId': messageId,
      'chatId': chatId,
      'content': content,
      'role': role,
      'files': files,
      'type': type,
      'tool_calls': toolCalls?.map((e) {
        return {
          'name': e.name,
          'arguments': e.arguments,
        };
      }).toList(),
      'tool_result': toolResult == null
          ? null
          : {
              'name': toolResult!.name,
              'result': toolResult!.result,
            },
    };
  }
}
