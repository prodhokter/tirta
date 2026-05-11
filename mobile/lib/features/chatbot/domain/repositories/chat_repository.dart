import 'package:tirta/features/chatbot/domain/entities/chat_message.dart';

abstract class ChatRepository {
  Future<ChatMessage> sendMessage({
    required String sessionId,
    required List<ChatMessage> messages,
  });

  Future<List<ChatMessage>> getChatHistory(String sessionId);

  Future<String> createSession();

  Future<void> saveMessage(ChatMessage message);
}
