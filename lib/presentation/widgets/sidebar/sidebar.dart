import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../blocs/chat/chat_state.dart';
import 'history_list.dart';

class Sidebar extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;
  final VoidCallback onCollapse;

  const Sidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
    required this.onCollapse,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  void initState() {
    super.initState();
    // 載入歷史對話列表
    context.read<ChatBloc>().add(LoadChatHistory());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 0),
      transform: Matrix4.translationValues(
        widget.isCollapsed ? -280 : 0,
        0,
        0,
      ),
      child: SizedBox(
        width: 280,
        child: Drawer(
          elevation: 1,
          child: Column(
            children: [
              // 頂部欄，包含收起按鈕
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu_rounded),
                      onPressed: widget.onToggle,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '對話歷史',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // 新對話按鈕
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<ChatBloc>().add(const LoadChat());
                    widget.onCollapse();
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Row(
                    children: [
                      Text('新對話'),
                      Spacer(),
                      Icon(
                        Icons.edit,
                        size: 16,
                        // color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 15,
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
              // 歷史對話列表
              Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state is ChatError) {
                      return Center(
                        child: Text('錯誤: ${state.message}'),
                      );
                    }

                    if (state is ChatSuccess) {
                      final chatHistory = state.chatHistory;
                      if (chatHistory == null || chatHistory.isEmpty) {
                        return const Center(
                          child: Text('尚無對話歷史'),
                        );
                      }

                      return HistoryList(
                        chatHistory: chatHistory,
                        currentChatId: state.currentChatId,
                        onCollapse: widget.onCollapse,
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
              // 底部操作按鈕
              Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [                    
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
