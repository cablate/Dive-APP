/**
 * 使用 equatable 套件來簡化相等性比較
 * 用於在bloc模式中比較狀態是否相同
 */
import 'package:equatable/equatable.dart';

import '../../../domain/entities/chat_history.dart';
import '../../../domain/entities/chat_message.dart';

/**
 * ChatState 是所有聊天相關狀態的基礎類別
 * 定義了基本的狀態結構和相等性比較
 */
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/**
 * ChatInitial 表示聊天的初始狀態
 * 當應用程式剛啟動或重置時使用
 */
class ChatInitial extends ChatState {}

/**
 * ChatLoading 表示正在載入資料的狀態
 * 例如：正在載入聊天記錄或刪除聊天時
 */
class ChatLoading extends ChatState {}

/**
 * ChatSuccess 表示操作成功的狀態
 * 包含當前的訊息列表和相關資訊
 */
class ChatSuccess extends ChatState {
  /** 
   * messages: 目前的訊息列表
   * currentChatId: 當前聊天的ID
   * isLoading: 是否正在等待新的訊息（用於串流響應）
   * chatHistory: 聊天歷史記錄列表
   * currentChat: 當前聊天的歷史記錄
   */
  final List<ChatMessage> messages;
  final String? currentChatId;
  final bool isLoading;
  final List<ChatHistory>? chatHistory;
  final ChatHistory? currentChat;

  const ChatSuccess({
    required this.messages,
    this.currentChatId,
    this.isLoading = false,
    this.chatHistory,
    this.currentChat,
  });

  @override
  List<Object?> get props => [
        messages,
        currentChatId,
        isLoading,
        chatHistory,
        currentChat,
      ];

  ChatSuccess copyWith({
    List<ChatMessage>? messages,
    String? currentChatId,
    bool? isLoading,
    List<ChatHistory>? chatHistory,
    ChatHistory? currentChat,
  }) {
    return ChatSuccess(
      messages: messages ?? this.messages,
      currentChatId: currentChatId ?? this.currentChatId,
      isLoading: isLoading ?? this.isLoading,
      chatHistory: chatHistory ?? this.chatHistory,
      currentChat: currentChat ?? this.currentChat,
    );
  }
}

/**
 * ChatError 表示發生錯誤的狀態
 * 包含錯誤訊息
 */
class ChatError extends ChatState {
  /** 
   * message: 錯誤訊息的內容
   */
  final String message;

  const ChatError({required this.message});

  @override
  List<Object?> get props => [message];
}
