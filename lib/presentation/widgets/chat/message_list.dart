import 'package:flutter/material.dart';

import '../../../domain/entities/chat_message.dart';
import 'message_item.dart';

class MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final bool isLoading;

  const MessageList({
    super.key,
    required this.messages,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return messages.isEmpty
        ? const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '歡迎使用 Dive',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '我可以為你做什麼？',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 32),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      '與我對話，探索無限可能',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      '我能協助你解決問題、激發創意',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.code, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      '一起探索程式的奧妙',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        : ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[messages.length - 1 - index];
              return ChatMessageItem(
                message: message,
                isLoading:
                    isLoading && index == 0 && message.role == 'assistant',
              );
            },
          );
  }
}
