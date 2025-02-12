import '../../domain/entities/chat_history.dart';

class ChatHistoryModel extends ChatHistory {
  const ChatHistoryModel({
    required super.id,
    required super.title,
    required super.createdAt,
  });

  factory ChatHistoryModel.fromJson(Map<String, dynamic> json) {
    return ChatHistoryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'message_count': messageCount,
    };
  }
}
