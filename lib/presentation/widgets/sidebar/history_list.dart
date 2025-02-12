import 'package:flutter/material.dart';

import '../../../domain/entities/chat_history.dart';
import 'history_item.dart';

class HistoryList extends StatelessWidget {
  final List<ChatHistory> chatHistory;
  final String? currentChatId;
  final VoidCallback onCollapse;

  const HistoryList({
    super.key,
    required this.chatHistory,
    this.currentChatId,
    required this.onCollapse,
  });

  @override
  Widget build(BuildContext context) {
    // 按創建時間排序，最新的在前面
    final sortedHistory = List<ChatHistory>.from(chatHistory)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 分組歷史記錄
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastWeek = today.subtract(const Duration(days: 7));

    final Map<String, List<ChatHistory>> groupedHistory = {
      '今天': [],
      '昨天': [],
      '過去7天': [],
      '更早': [],
    };

    for (final chat in sortedHistory) {
      final chatDate = DateTime(
        chat.createdAt.year,
        chat.createdAt.month,
        chat.createdAt.day,
      );

      if (chatDate == today) {
        groupedHistory['今天']!.add(chat);
      } else if (chatDate == yesterday) {
        groupedHistory['昨天']!.add(chat);
      } else if (chatDate.isAfter(lastWeek)) {
        groupedHistory['過去7天']!.add(chat);
      } else {
        groupedHistory['更早']!.add(chat);
      }
    }

    return ListView.builder(
      itemCount: groupedHistory.length,
      itemBuilder: (context, index) {
        final groupTitle = groupedHistory.keys.elementAt(index);
        final groupChats = groupedHistory[groupTitle]!;

        if (groupChats.isEmpty) {
          return const SizedBox();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                groupTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            ...groupChats.map(
              (chat) => HistoryItem(
                key: ValueKey(chat.id),
                chat: chat,
                isSelected: chat.id == currentChatId,
                onCollapse: onCollapse,
              ),
            ),
          ],
        );
      },
    );
  }
}
