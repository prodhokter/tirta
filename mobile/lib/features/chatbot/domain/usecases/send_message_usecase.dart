import 'package:tirta/features/chatbot/domain/entities/chat_message.dart';
import 'package:tirta/features/chatbot/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository _repository;

  SendMessageUseCase(this._repository);

  Future<ChatMessage> call({
    required String sessionId,
    required List<ChatMessage> messages,
  }) async {
    return await _repository.sendMessage(
      sessionId: sessionId,
      messages: messages,
    );
  }
}
