import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tirta/features/chatbot/data/datasources/chat_local_datasource.dart';
import 'package:tirta/features/chatbot/data/datasources/chat_remote_datasource.dart';
import 'package:tirta/features/chatbot/data/repositories/chat_repository_impl.dart';
import 'package:tirta/features/chatbot/domain/entities/chat_message.dart';
import 'package:tirta/features/chatbot/domain/usecases/get_chat_history_usecase.dart';
import 'package:tirta/features/chatbot/domain/usecases/send_message_usecase.dart';
import 'package:tirta/core/constants/app_strings.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final String? sessionId;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.sessionId,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    String? sessionId,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final SendMessageUseCase _sendMessageUseCase;
  final GetChatHistoryUseCase _getChatHistoryUseCase;
  final ChatRepositoryImpl _repository;

  ChatNotifier({
    required SendMessageUseCase sendMessageUseCase,
    required GetChatHistoryUseCase getChatHistoryUseCase,
    required ChatRepositoryImpl repository,
  })  : _sendMessageUseCase = sendMessageUseCase,
        _getChatHistoryUseCase = getChatHistoryUseCase,
        _repository = repository,
        super(const ChatState());

  Future<void> loadChatHistory() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final sessionId = await _ensureSession();

      final messages = await _getChatHistoryUseCase(sessionId);

      state = state.copyWith(
        messages: messages,
        isLoading: false,
        sessionId: sessionId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendMessage(String text) async {
    _sendMessageInternal(text);
  }

  Future<void> sendMessageWithQuickReply(String text) async {
    _sendMessageInternal(text);
  }

  Future<void> _sendMessageInternal(String text) async {
    if (text.trim().isEmpty) return;

    try {
      final sessionId = await _ensureSession();

      final userMessage = ChatMessage(
        sessionId: sessionId,
        role: 'user',
        content: text.trim(),
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, userMessage],
        isLoading: true,
        error: null,
      );

      await _saveMessageToSupabase(userMessage);

      final contextMessages = [...state.messages];

      final assistantMessage = await _sendMessageUseCase(
        sessionId: sessionId,
        messages: contextMessages,
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
      );
    } catch (e) {
      final errorMessage = ChatMessage(
        sessionId: state.sessionId,
        role: 'assistant',
        content: AppStrings.chatError,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _saveMessageToSupabase(ChatMessage message) async {
    try {
      await _repository.saveMessage(message);
    } catch (_) {
      // Silently fail - message is still shown in UI
    }
  }

  Future<String> _ensureSession() async {
    if (state.sessionId != null) {
      return state.sessionId!;
    }

    final localDatasource = ChatLocalDatasource();
    final existingSession = await localDatasource.getLatestSession();

    if (existingSession != null) {
      state = state.copyWith(sessionId: existingSession);
      return existingSession;
    }

    final newSessionId = await _repository.createSession();
    state = state.copyWith(sessionId: newSessionId);
    return newSessionId;
  }
}

// Providers
final _chatRepositoryProvider = Provider<ChatRepositoryImpl>((ref) {
  return ChatRepositoryImpl(
    remoteDatasource: ChatRemoteDatasource(),
    localDatasource: ChatLocalDatasource(),
  );
});

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final repository = ref.watch(_chatRepositoryProvider);
  return ChatNotifier(
    sendMessageUseCase: SendMessageUseCase(repository),
    getChatHistoryUseCase: GetChatHistoryUseCase(repository),
    repository: repository,
  );
});
