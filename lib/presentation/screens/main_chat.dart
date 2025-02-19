/** 
 * Flutter的基本UI元件庫，包含了Material Design風格的元件
 */
import 'package:flutter/material.dart';
/** 
 * flutter_bloc是一個狀態管理套件，用於處理應用程式的狀態變化
 * Bloc模式是Business Logic Component的縮寫，用於分離UI和業務邏輯
 */
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mcp_chat/presentation/blocs/chat/chat_event.dart';

import '../blocs/chat/chat_bloc.dart';
import '../blocs/chat/chat_state.dart';
import '../widgets/chat/message_input.dart';
import '../widgets/chat/message_list.dart';
import '../widgets/sidebar/sidebar.dart';

/**
 * StatefulWidget是一個可以保持狀態的widget，適用於需要保持狀態的UI元件
 */
class ChatScreen extends StatefulWidget {
  /** 
   * const constructor可以在編譯時期就建立物件，提升效能
   * super.key是用來識別widget的唯一標識，通常用於動畫或保持狀態
   */
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isSidebarCollapsed = true;

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    /** 
     * Scaffold是Material Design的基本頁面結構
     * 提供了標準的應用程式介面框架，包含AppBar、Body、BottomNavigationBar等
     */
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 主要聊天區域
            AnimatedContainer(
              duration: const Duration(milliseconds: 0),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(
                _isSidebarCollapsed ? 0 : 280,
                0,
                0,
              ),
              child: Stack(
                children: [
                  BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      /** 
                       * 當狀態是ChatLoading時，顯示載入中的圓形進度指示器
                       */
                      if (state is ChatLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      /** 
                       * 當狀態是ChatError時，顯示錯誤訊息
                       */
                      if (state is ChatError) {
                        return Center(
                          child: Text('錯誤: ${state.message}'),
                        );
                      }

                      /** 
                       * 當狀態是ChatSuccess時，顯示聊天的主要介面
                       * Column是一個垂直排列子元件的容器
                       */
                      if (state is ChatSuccess) {
                        return Column(
                          children: [
                            // 頂部標題欄
                            Container(
                              height: 60,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  if (_isSidebarCollapsed)
                                    IconButton(
                                      icon: const Icon(Icons.menu_rounded),
                                      onPressed: _toggleSidebar,
                                    ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.currentChat?.title ?? 'Dive',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.build),
                                    tooltip: '可用工具',
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/tools');
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.settings),
                                    tooltip: '工具配置',
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/tool-config');
                                    },
                                  ),
                                  if (state.currentChat != null)
                                    IconButton(
                                      icon: const Icon(Icons.note_add_outlined),
                                      onPressed: () {
                                        context
                                            .read<ChatBloc>()
                                            .add(const LoadChat());
                                      },
                                      tooltip: '新對話',
                                    ),
                                ],
                              ),
                            ),
                            // 訊息列表
                            Expanded(
                              child: MessageList(
                                messages: state.messages,
                                isLoading: state.isLoading,
                              ),
                            ),
                            // 輸入框
                            const MessageInput(),
                          ],
                        );
                      }

                      /** 
                       * 預設狀態：顯示歡迎訊息和輸入框
                       */
                      return Column(
                        children: [
                          // 頂部標題欄
                          Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              border: Border(
                                bottom: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                if (_isSidebarCollapsed)
                                  IconButton(
                                    icon: const Icon(Icons.menu_rounded),
                                    onPressed: _toggleSidebar,
                                  ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Dive',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.build),
                                  tooltip: '可用工具',
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/tools');
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.settings),
                                  tooltip: '工具配置',
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/tool-config');
                                  },
                                ),
                              ],
                            ),
                          ),
                          const Expanded(
                            child: Center(
                              child: MessageList(
                                messages: [],
                                isLoading: false,
                              ),
                            ),
                          ),
                          const MessageInput(),
                        ],
                      );
                    },
                  ),
                  // 側邊欄展開時的點擊遮罩
                  if (!_isSidebarCollapsed)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _toggleSidebar,
                        child: Container(
                          color: Colors.black12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // 側邊欄
            Sidebar(
              isCollapsed: _isSidebarCollapsed,
              onToggle: _toggleSidebar,
              onCollapse: () => setState(() => _isSidebarCollapsed = true),
            ),
          ],
        ),
      ),
    );
  }
}
