import '../entities/chat_history.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  Stream<List<ChatMessage>> sendMessageStream({
    required String message,
    List<String>? files,
    String? chatId,
  });

  Future<List<ChatMessage>> loadChat(String? chatId);

  Future<void> deleteChat(String chatId);

  Future<List<ChatHistory>> getChatHistory();

  Future<void> updateChatTitle(String chatId, String title);

  Future<void> deleteAllChats();

  // Future<ChatHistory?> getCurrentChat();
}
