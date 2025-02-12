import '../../domain/entities/chat_history.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../providers/chat_api_provider.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatApiProvider _apiProvider;

  ChatRepositoryImpl({ChatApiProvider? apiProvider})
      : _apiProvider = apiProvider ?? ChatApiProvider();

  @override
  Stream<List<ChatMessage>> sendMessageStream({
    required String message,
    List<String>? files,
    String? chatId,
  }) async* {
    await for (final messages in _apiProvider.sendMessageStream(
      message: message,
      files: files,
      chatId: chatId,
    )) {
      yield messages.map((m) => m as ChatMessage).toList();
    }
  }

  @override
  Future<List<ChatMessage>> loadChat(String? chatId) async {
    return await _apiProvider.loadChat(chatId);
  }

  @override
  Future<void> deleteChat(String chatId) async {
    await _apiProvider.deleteChat(chatId);
  }

  @override
  Future<List<ChatHistory>> getChatHistory() async {
    final historyList = await _apiProvider.getChatHistory();
    return historyList.map((h) => h as ChatHistory).toList().take(20).toList();
  }

  @override
  Future<void> updateChatTitle(String chatId, String title) async {
    await _apiProvider.updateChatTitle(chatId, title);
  }

  @override
  Future<void> deleteAllChats() async {
    await _apiProvider.deleteAllChats();
  }

  // @override
  // Future<ChatHistory?> getCurrentChat() async {
  //   final currentChat = await _apiProvider.getCurrentChat();
  //   return currentChat;
  // }
}
