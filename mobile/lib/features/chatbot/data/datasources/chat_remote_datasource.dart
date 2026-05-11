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
      '/api/chat',
      data: {
        'messages': messagesJson,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('response')) {
        return data['response'] as String;
      }
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'] as String;
      }
      if (data is Map<String, dynamic> && data.containsKey('content')) {
        return data['content'] as String;
      }
      return data.toString();
    }

    throw Exception('Gagal mendapatkan respons dari server');
  }
}
