import 'package:equatable/equatable.dart';

class ChatHistory extends Equatable {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? messageCount;

  const ChatHistory({
    required this.id,
    required this.title,
    required this.createdAt,
    this.updatedAt,
    this.messageCount,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        createdAt,
        updatedAt,
        messageCount,
      ];
} 