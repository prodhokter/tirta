import 'package:tirta/features/chatbot/domain/entities/chat_message.dart';
import 'package:tirta/features/chatbot/domain/repositories/chat_repository.dart';

class GetChatHistoryUseCase {
  final ChatRepository _repository;

  GetChatHistoryUseCase(this._repository);

  Future<List<ChatMessage>> call(String sessionId) async {
    return await _repository.getChatHistory(sessionId);
  }
}
