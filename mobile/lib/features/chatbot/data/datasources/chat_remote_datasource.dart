import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:tirta/features/chatbot/domain/entities/chat_message.dart';
import 'package:tirta/shared/services/api_service.dart';

class ChatRemoteDatasource {
  final Dio _dio = ApiService().dio;

  Future<String> sendMessage(List<ChatMessage> messages) async {
    final messagesJson = messages
        .map((m) => {
              'role': m.role,
              'content': m.content,
            })
        .toList();

    final response = await _dio.post(
      '/chat',
      data: {
        'messages': messagesJson,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data') && data['data'] is Map) {
        final inner = data['data'] as Map<String, dynamic>;
        if (inner.containsKey('response')) {
          return inner['response'] as String;
        }
      }
      if (data.containsKey('response')) {
        return data['response'] as String;
      }
      if (data.containsKey('message')) {
        return data['message'] as String;
      }
    }

    throw Exception('Gagal mendapatkan respons dari server');
  }

  /// Sends messages and returns a stream of content chunks via SSE.
  Stream<String> sendMessageStream(List<ChatMessage> messages) async* {
    final messagesJson = messages
        .map((m) => {
              'role': m.role,
              'content': m.content,
            })
        .toList();

    Response<ResponseBody> response;
    try {
      response = await _dio.post<ResponseBody>(
        '/chat/stream',
        data: {'messages': messagesJson},
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
          },
        ),
      );
    } on DioException catch (e) {
      // If streaming endpoint doesn't exist yet, fall back to non-streaming
      if (e.response?.statusCode == 404) {
        final result = await sendMessage(messages);
        yield result;
        return;
      }
      rethrow;
    }

    final stream = response.data?.stream;
    if (stream == null) {
      final result = await sendMessage(messages);
      yield result;
      return;
    }

    String buffer = '';
    await for (final chunk in stream) {
      buffer += utf8.decode(chunk, allowMalformed: true);
      final lines = buffer.split('\n');
      buffer = lines.removeLast(); // keep incomplete line in buffer

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || !trimmed.startsWith('data:')) continue;

        final data = trimmed.substring(5).trim();
        if (data == '[DONE]') return;

        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          if (json.containsKey('error')) {
            throw Exception(json['error'] as String);
          }
          if (json.containsKey('content')) {
            yield json['content'] as String;
          }
        } catch (e) {
          if (e is Exception) rethrow;
          // Ignore malformed JSON lines
        }
      }
    }
  }
}
