import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/chat_history.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';

class HistoryItem extends StatefulWidget {
  final ChatHistory chat;
  final bool isSelected;
  final VoidCallback onCollapse;

  const HistoryItem({
    super.key,
    required this.chat,
    this.isSelected = false,
    required this.onCollapse,
  });

  @override
  State<HistoryItem> createState() => _HistoryItemState();
}

class _HistoryItemState extends State<HistoryItem> {
  final TextEditingController _titleController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.chat.title;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _stopEditing() {
    if (_titleController.text != widget.chat.title) {
      context.read<ChatBloc>().add(
            UpdateChatTitle(
              chatId: widget.chat.id,
              title: _titleController.text,
            ),
          );
    }
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('MM/dd HH:mm').format(widget.chat.createdAt);

    return Material(
      color: widget.isSelected
          ? theme.colorScheme.primaryContainer
          : Colors.transparent,
      child: InkWell(
        onTap: () {
          context.read<ChatBloc>().add(LoadChat(chatId: widget.chat.id));
          widget.onCollapse();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          child: Row(
            children: [
              // Icon(
              //   Icons.chat_bubble_outline_rounded,
              //   color: widget.isSelected
              //       ? theme.colorScheme.primary
              //       : theme.iconTheme.color,
              // ),
              const SizedBox(width: 10),
              // 標題和時間
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isEditing)
                      TextField(
                        controller: _titleController,
                        autofocus: true,
                        onSubmitted: (_) => _stopEditing(),
                        onEditingComplete: _stopEditing,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                        ),
                      )
                    else
                      Text(
                        widget.chat.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: widget.isSelected
                              ? theme.colorScheme.primary
                              : null,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // 操作按鈕
              if (!_isEditing) ...[
                // IconButton(
                //   icon: const Icon(Icons.edit_outlined),
                //   iconSize: 20,
                //   visualDensity: VisualDensity.compact,
                //   onPressed: _startEditing,
                //   tooltip: '編輯標題',
                // ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('確認刪除'),
                        content: const Text('確定要刪除這個對話嗎？'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              context
                                  .read<ChatBloc>()
                                  .add(DeleteChat(chatId: widget.chat.id));
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              '確定',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  tooltip: '刪除對話',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
