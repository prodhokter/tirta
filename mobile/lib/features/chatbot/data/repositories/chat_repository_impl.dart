import 'dart:async';
import 'package:tirta/features/chatbot/data/datasources/chat_local_datasource.dart';
import 'package:tirta/features/chatbot/data/datasources/chat_remote_datasource.dart';
import 'package:tirta/features/chatbot/domain/entities/chat_message.dart';
import 'package:tirta/features/chatbot/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource _remoteDatasource;
  final ChatLocalDatasource _localDatasource;

  ChatRepositoryImpl({
    required ChatRemoteDatasource remoteDatasource,
    required ChatLocalDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  @override
  Future<ChatMessage> sendMessage({
    required String sessionId,
    required List<ChatMessage> messages,
  }) async {
    final aiContent = await _remoteDatasource.sendMessage(messages);

    final assistantMessage = ChatMessage(
      sessionId: sessionId,
      role: 'assistant',
      content: aiContent,
      createdAt: DateTime.now(),
    );

    final savedMessage = await _localDatasource.saveMessage(assistantMessage);

    return savedMessage;
  }

  /// Streaming version — yields content chunks and saves the full message at the end.
  Stream<String> sendMessageStream({
    required String sessionId,
    required List<ChatMessage> messages,
  }) async* {
    final buffer = StringBuffer();

    await for (final chunk in _remoteDatasource.sendMessageStream(messages)) {
      buffer.write(chunk);
      yield chunk;
    }

    // Save the complete message to Supabase after streaming finishes
    final assistantMessage = ChatMessage(
      sessionId: sessionId,
      role: 'assistant',
      content: buffer.toString(),
      createdAt: DateTime.now(),
    );

    try {
      await _localDatasource.saveMessage(assistantMessage);
    } catch (_) {
      // Silently fail — message is still shown in UI
    }
  }

  @override
  Future<List<ChatMessage>> getChatHistory(String sessionId) async {
    return await _localDatasource.getMessages(sessionId);
  }

  @override
  Future<String> createSession() async {
    return await _localDatasource.createSession();
  }

  @override
  Future<void> saveMessage(ChatMessage message) async {
    await _localDatasource.saveMessage(message);
  }
}
