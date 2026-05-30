import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tirta/features/chatbot/data/datasources/chat_local_datasource.dart';
import 'package:tirta/features/chatbot/data/datasources/chat_remote_datasource.dart';
import 'package:tirta/features/chatbot/data/repositories/chat_repository_impl.dart';
import 'package:tirta/features/chatbot/domain/entities/chat_message.dart';
import 'package:tirta/features/chatbot/domain/usecases/get_chat_history_usecase.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isStreaming;
  final String? error;
  final String? sessionId;
  final String? sessionTitle;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isStreaming = false,
    this.error,
    this.sessionId,
    this.sessionTitle,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isStreaming,
    String? error,
    String? sessionId,
    String? sessionTitle,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isStreaming: isStreaming ?? this.isStreaming,
      error: error,
      sessionId: sessionId ?? this.sessionId,
      sessionTitle: sessionTitle ?? this.sessionTitle,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final GetChatHistoryUseCase _getChatHistoryUseCase;
  final ChatRepositoryImpl _repository;
  StreamSubscription? _streamSubscription;

  ChatNotifier({
    required GetChatHistoryUseCase getChatHistoryUseCase,
    required ChatRepositoryImpl repository,
  })  : _getChatHistoryUseCase = getChatHistoryUseCase,
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

      final placeholderMessage = ChatMessage(
        sessionId: sessionId,
        role: 'assistant',
        content: '',
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, userMessage, placeholderMessage],
        isLoading: true,
        isStreaming: true,
        error: null,
      );

      await _saveMessageToSupabase(userMessage);

      final contextMessages = buildContextMessages(state.messages);

      final stream = _repository.sendMessageStream(
        sessionId: sessionId,
        messages: contextMessages,
      );

      final buffer = StringBuffer();

      _streamSubscription = stream.listen(
        (chunk) {
          buffer.write(chunk);
          final updatedMessages = List<ChatMessage>.from(state.messages);
          if (updatedMessages.isNotEmpty && updatedMessages.last.role == 'assistant') {
            updatedMessages[updatedMessages.length - 1] = ChatMessage(
              sessionId: sessionId,
              role: 'assistant',
              content: buffer.toString(),
              createdAt: DateTime.now(),
            );
          }
          state = state.copyWith(messages: updatedMessages);
        },
        onDone: () {
          final finalMessages = List<ChatMessage>.from(state.messages);
          state = state.copyWith(
            messages: finalMessages,
            isLoading: false,
            isStreaming: false,
          );
        },
        onError: (e) {
          final errorMessage = ChatMessage(
            sessionId: state.sessionId,
            role: 'assistant',
            content: _formatError(e),
            createdAt: DateTime.now(),
          );
          final updatedMessages = List<ChatMessage>.from(state.messages);
          if (updatedMessages.isNotEmpty && updatedMessages.last.role == 'assistant' && updatedMessages.last.content.isEmpty) {
            updatedMessages[updatedMessages.length - 1] = errorMessage;
          } else {
            updatedMessages.add(errorMessage);
          }
          state = state.copyWith(
            messages: updatedMessages,
            isLoading: false,
            isStreaming: false,
            error: e.toString(),
          );
        },
        cancelOnError: true,
      );
    } catch (e) {
      final errorMessage = ChatMessage(
        sessionId: state.sessionId,
        role: 'assistant',
        content: _formatError(e),
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
        isStreaming: false,
        error: e.toString(),
      );
    }
  }

  /// Build conversation context: only send recent messages that are user/assistant
  /// with content, keeping the AI's context window manageable.
  List<ChatMessage> buildContextMessages(List<ChatMessage> allMessages) {
    final contextMessages = allMessages
        .where((m) => m.content.isNotEmpty && (m.role == 'user' || m.role == 'assistant'))
        .toList();

    // Keep last 30 messages (15 conversation turns) for context
    // DeepSeek v4 has large context window but we keep it focused
    if (contextMessages.length > 30) {
      return contextMessages.sublist(contextMessages.length - 30);
    }
    return contextMessages;
  }

  Future<void> clearChat() async {
    _streamSubscription?.cancel();

    try {
      final newSessionId = await _repository.createSession();
      state = ChatState(sessionId: newSessionId);
    } catch (_) {
      state = const ChatState();
    }
  }

  Future<void> retryLastMessage() async {
    if (state.messages.isEmpty) return;

    ChatMessage? lastUserMessage;
    for (int i = state.messages.length - 1; i >= 0; i--) {
      if (state.messages[i].role == 'user') {
        lastUserMessage = state.messages[i];
        break;
      }
    }

    if (lastUserMessage == null) return;

    final lastUserIndex = state.messages.indexOf(lastUserMessage);
    final trimmedMessages = state.messages.sublist(0, lastUserIndex);

    state = state.copyWith(
      messages: trimmedMessages,
      error: null,
    );

    _sendMessageInternal(lastUserMessage.content);
  }

  String _formatError(Object e) {
    final raw = e.toString();
    if (raw.contains('Connection refused') || raw.contains('SocketException') || raw.contains('No address')) {
      return 'Gagal terhubung ke server. Periksa koneksi internet kamu.';
    }
    if (raw.contains('timeout') || raw.contains('Time out')) {
      return 'Respons server terlalu lama. Silakan coba lagi.';
    }
    if (raw.contains('401') || raw.contains('Unauthorized') || raw.contains('Invalid token')) {
      return 'Sesi kamu berakhir. Silakan login ulang.';
    }
    if (raw.contains('429')) {
      return 'Terlalu banyak permintaan. Tunggu sebentar, ya.';
    }
    if (raw.contains('500') || raw.contains('502') || raw.contains('503')) {
      return 'Server sedang sibuk. Silakan coba lagi nanti.';
    }
    // Truncate long error messages
    if (raw.length > 150) {
      return 'Gagal: ${raw.substring(0, 150)}...';
    }
    return 'Gagal: $raw';
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

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
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
    getChatHistoryUseCase: GetChatHistoryUseCase(repository),
    repository: repository,
  );
});
