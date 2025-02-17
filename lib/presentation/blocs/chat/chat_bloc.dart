/**
 * flutter_bloc 用於實作 BLoC (Business Logic Component) 模式
 * 用來分離業務邏輯和UI層
 */
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/chat_history.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

/**
 * ChatBloc 負責處理所有聊天相關的業務邏輯
 * 接收事件(ChatEvent)並產生對應的狀態(ChatState)
 */
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  /** 
   * _repository: 用於與資料層互動的儲存庫
   * _messages: 儲存當前的訊息列表
   * _currentChatId: 當前聊天的ID
   * _chatHistory: 儲存聊天歷史記錄
   * _currentChat: 當前聊天的聊天記錄
   */
  final ChatRepository _repository;
  List<ChatMessage> _messages = [];
  String? _currentChatId;
  List<ChatHistory>? _chatHistory;
  ChatHistory? _currentChat;

  ChatBloc({required ChatRepository repository})
      : _repository = repository,
        super(ChatInitial()) {
    /** 
     * 註冊各種事件的處理方法
     */
    on<SendMessage>(_onSendMessage);
    on<LoadChat>(_onLoadChat);
    on<DeleteChat>(_onDeleteChat);
    on<LoadChatHistory>(_onLoadChatHistory);
    on<UpdateChatTitle>(_onUpdateChatTitle);
    on<DeleteAllChats>(_onDeleteAllChats);
    on<UpdateChatInfo>(_onUpdateChatInfo);
    // on<GetCurrentChat>(_onGetCurrentChat);
  }

  /** 
   * _onSendMessage 處理發送訊息的事件
   * 包含發送訊息到API和處理串流回應
   */
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      /** 
       * 建立新的使用者訊息
       */
      final message = ChatMessage(
        id: DateTime.now().toString(),
        messageId: DateTime.now().toString(),
        chatId: _currentChatId ?? '',
        content: event.message,
        role: 'user',
        type: 'text',
        files: event.files,
      );

      /** 
       * 立即顯示使用者訊息
       */
      _messages = [..._messages, message];

      if (state is ChatSuccess) {
        emit((state as ChatSuccess).copyWith(
          messages: List.from(_messages),
          isLoading: true,
        ));
      } else {
        emit(ChatSuccess(
          messages: List.from(_messages),
          currentChatId: _currentChatId,
          isLoading: true,
          chatHistory: _chatHistory,
          currentChat: _currentChat,
        ));
      }

      /** 
       * 發送訊息到API並處理串流回應
       */
      String? lastMessageId;

      await for (final responses in _repository.sendMessageStream(
        message: event.message,
        files: event.files,
        chatId: _currentChatId ?? '',
      )) {
        if (responses.isEmpty) {
          continue;
        }

        final assistantMessage = responses.first;

        // 處理 chat_info 類型的訊息
        if (assistantMessage.type == 'chat_info') {
          // 更新當前對話資訊
          _currentChatId = assistantMessage.chatId;
          _currentChat = ChatHistory(
            id: assistantMessage.chatId,
            title: assistantMessage.title ?? 'New Chat',
            createdAt: DateTime.now(),
          );

          // 發出更新後的狀態
          if (state is ChatSuccess) {
            emit((state as ChatSuccess).copyWith(
              currentChatId: _currentChatId,
              currentChat: _currentChat,
            ));
          }
          continue;
        }

        /** 
         * 更新訊息列表
         * 如果是首次回應則新增訊息，否則更新現有訊息
         */
        if (lastMessageId == null) {
          print('加入了新訊息 - ${assistantMessage.id}');
          _messages = [..._messages, assistantMessage];
          lastMessageId = assistantMessage.id;
        } else {
          _messages = _messages.map((m) {
            if (m.id == lastMessageId) {
              return assistantMessage.copyWith(chatId: _currentChatId);
            }
            return m;
          }).toList();
        }

        if (state is ChatSuccess) {
          emit((state as ChatSuccess).copyWith(
            messages: List.from(_messages),
            isLoading: true,
          ));
        } else {
          emit(ChatSuccess(
            messages: List.from(_messages),
            currentChatId: _currentChatId,
            isLoading: true,
            chatHistory: _chatHistory,
            currentChat: _currentChat,
          ));
        }
      }

      /** 
       * 完成串流處理，發出最終狀態
       */
      if (state is ChatSuccess) {
        emit((state as ChatSuccess).copyWith(
          messages: List.from(_messages),
          isLoading: false,
        ));
      } else {
        emit(ChatSuccess(
          messages: List.from(_messages),
          currentChatId: _currentChatId,
          isLoading: false,
          chatHistory: _chatHistory,
          currentChat: _currentChat,
        ));
      }
    } catch (e) {
      print('發生錯誤: $e');
      emit(ChatError(message: e.toString()));
    }
  }

  /** 
   * _onLoadChat 處理載入聊天記錄的事件
   * 從儲存庫載入指定ID的聊天記錄
   */
  Future<void> _onLoadChat(
    LoadChat event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // 如果已經在新對話，則不進行任何操作
      if (event.chatId == null && _currentChatId == null) {
        return;
      }

      // 如果是切換到新對話
      if (event.chatId == null && _currentChatId != null) {
        _chatHistory = await _repository.getChatHistory();
        _currentChatId = null;
        _currentChat = null;
        _messages = [];

        emit(ChatSuccess(
          messages: _messages,
          currentChatId: _currentChatId,
          chatHistory: _chatHistory,
          currentChat: _currentChat,
        ));
        return;
      }

      emit(ChatLoading());

      _messages = await _repository.loadChat(event.chatId);
      _currentChatId = event.chatId;

      if (event.chatId != null && _chatHistory != null) {
        _currentChat = _chatHistory!.firstWhere(
          (chat) => chat.id == event.chatId,
          orElse: () => _currentChat!,
        );
      } else {
        _currentChat = null;
      }

      emit(ChatSuccess(
        messages: _messages,
        currentChatId: _currentChatId,
        chatHistory: _chatHistory,
        currentChat: _currentChat,
      ));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  /** 
   * _onDeleteChat 處理刪除聊天的事件
   * 刪除指定ID的聊天記錄並清空當前狀態
   */
  Future<void> _onDeleteChat(
    DeleteChat event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());
      await _repository.deleteChat(event.chatId);

      _chatHistory = await _repository.getChatHistory();

      if (_currentChatId == event.chatId) {
        _messages = [];
        _currentChatId = null;
        _currentChat = null;
      }

      emit(ChatSuccess(
        messages: _messages,
        currentChatId: _currentChatId,
        chatHistory: _chatHistory,
        currentChat: _currentChat,
      ));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistory event,
    Emitter<ChatState> emit,
  ) async {
    try {
      if (state is ChatSuccess) {
        emit((state as ChatSuccess).copyWith(isLoading: true));
      } else {
        emit(ChatLoading());
      }

      _chatHistory = await _repository.getChatHistory();

      if (state is ChatSuccess) {
        emit((state as ChatSuccess).copyWith(
          chatHistory: _chatHistory,
          isLoading: false,
        ));
      } else {
        emit(ChatSuccess(
          messages: _messages,
          currentChatId: _currentChatId,
          chatHistory: _chatHistory,
          currentChat: _currentChat,
        ));
      }
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onUpdateChatTitle(
    UpdateChatTitle event,
    Emitter<ChatState> emit,
  ) async {
    try {
      if (state is ChatSuccess) {
        emit((state as ChatSuccess).copyWith(isLoading: true));
      } else {
        emit(ChatLoading());
      }

      if (_currentChatId != event.chatId) {
        throw Exception('_onUpdateChatTitle: chatId 不相符');
      }

      await _repository.updateChatTitle(event.chatId, event.title);

      _chatHistory = await _repository.getChatHistory();

      if (state is ChatSuccess) {
        emit((state as ChatSuccess).copyWith(
          chatHistory: _chatHistory,
          currentChat: _currentChat,
          isLoading: false,
        ));
      } else {
        emit(ChatSuccess(
          messages: _messages,
          currentChatId: _currentChatId,
          chatHistory: _chatHistory,
          currentChat: _currentChat,
        ));
      }
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onDeleteAllChats(
    DeleteAllChats event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());
      await _repository.deleteAllChats();

      _messages = [];
      _currentChatId = null;
      _chatHistory = [];
      _currentChat = null;

      emit(ChatSuccess(
        messages: _messages,
        chatHistory: _chatHistory,
      ));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onUpdateChatInfo(
    UpdateChatInfo event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatSuccess) {
      _currentChatId = event.chatId;
      _currentChat = ChatHistory(
        id: event.chatId,
        title: event.title,
        createdAt: DateTime.now(),
      );

      emit((state as ChatSuccess).copyWith(
        currentChatId: _currentChatId,
        currentChat: _currentChat,
      ));
    }
  }

  // Future<void> _onGetCurrentChat(
  //   GetCurrentChat event,
  //   Emitter<ChatState> emit,
  // ) async {
  //   try {
  //     if (state is ChatSuccess) {
  //       emit((state as ChatSuccess).copyWith(isLoading: true));
  //     } else {
  //       emit(ChatLoading());
  //     }

  //     if (state is ChatSuccess) {
  //       emit((state as ChatSuccess).copyWith(
  //         currentChat: _currentChat,
  //         isLoading: false,
  //       ));
  //     } else {
  //       emit(ChatSuccess(
  //         messages: _messages,
  //         currentChatId: _currentChatId,
  //         chatHistory: _chatHistory,
  //         currentChat: _currentChat,
  //       ));
  //     }
  //   } catch (e) {
  //     emit(ChatError(message: e.toString()));
  //   }
  // }
}
