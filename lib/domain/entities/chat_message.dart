import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String messageId;
  final String chatId;
  final String content;
  final String role;
  final String type;
  final List<String>? files;
  final List<ToolCall>? toolCalls;
  final ToolResult? toolResult;
  final String? title;

  const ChatMessage({
    required this.id,
    required this.messageId,
    required this.chatId,
    required this.content,
    required this.role,
    required this.type,
    this.files,
    this.toolCalls,
    this.toolResult,
    this.title,
  });

  @override
  List<Object?> get props => [
        id,
        messageId,
        chatId,
        content,
        role,
        type,
        files,
        toolCalls,
        toolResult,
        title,
      ];

  ChatMessage copyWith({
    String? id,
    String? messageId,
    String? chatId,
    String? content,
    String? role,
    String? type,
    List<String>? files,
    List<ToolCall>? toolCalls,
    ToolResult? toolResult,
    String? title,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      chatId: chatId ?? this.chatId,
      content: content ?? this.content,
      role: role ?? this.role,
      type: type ?? this.type,
      files: files ?? this.files,
      toolCalls: toolCalls ?? this.toolCalls,
      toolResult: toolResult ?? this.toolResult,
      title: title ?? this.title,
    );
  }
}

class ToolCall extends Equatable {
  final String name;
  final Map<String, dynamic> arguments;

  const ToolCall({
    required this.name,
    required this.arguments,
  });

  @override
  List<Object?> get props => [name, arguments];
}

class ToolResult extends Equatable {
  final String name;
  final dynamic result;

  const ToolResult({
    required this.name,
    required this.result,
  });

  @override
  List<Object?> get props => [name, result];
}
