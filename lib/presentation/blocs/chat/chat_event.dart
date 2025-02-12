/**
 * 使用 equatable 套件來簡化相等性比較
 * 用於在bloc模式中比較事件是否相同
 */
import 'package:equatable/equatable.dart';

/**
 * ChatEvent 是所有聊天相關事件的基礎類別
 * 定義了基本的事件結構和相等性比較
 */
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/**
 * SendMessage 事件用於發送新訊息
 * 可以包含文字訊息和圖片檔案
 */
class SendMessage extends ChatEvent {
  /** 
   * message: 要發送的文字訊息
   * files: 要發送的圖片檔案列表（base64格式）
   */
  final String message;
  final List<String>? files;

  const SendMessage({
    required this.message,
    this.files,
  });

  @override
  List<Object?> get props => [message, files];
}

/**
 * LoadChat 事件用於載入特定的聊天記錄
 * 如果 chatId 為 null，則載入新的聊天
 */
class LoadChat extends ChatEvent {
  /** 
   * chatId: 要載入的聊天ID
   */
  final String? chatId;

  const LoadChat({this.chatId});

  @override
  List<Object?> get props => [chatId];
}

/**
 * DeleteChat 事件用於刪除特定的聊天記錄
 */
class DeleteChat extends ChatEvent {
  /** 
   * chatId: 要刪除的聊天ID
   */
  final String chatId;

  const DeleteChat({required this.chatId});

  @override
  List<Object?> get props => [chatId];
}

// 新增的事件
class LoadChatHistory extends ChatEvent {}

class UpdateChatTitle extends ChatEvent {
  final String chatId;
  final String title;

  const UpdateChatTitle({
    required this.chatId,
    required this.title,
  });

  @override
  List<Object?> get props => [chatId, title];
}

class DeleteAllChats extends ChatEvent {}

class UpdateChatInfo extends ChatEvent {
  final String chatId;
  final String title;

  const UpdateChatInfo({
    required this.chatId,
    required this.title,
  });

  @override
  List<Object?> get props => [chatId, title];
}

// class GetCurrentChat extends ChatEvent {}
