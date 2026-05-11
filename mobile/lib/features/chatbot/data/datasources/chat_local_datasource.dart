import 'package:uuid/uuid.dart';
import 'package:tirta/features/chatbot/data/models/chat_message_model.dart';
import 'package:tirta/features/chatbot/domain/entities/chat_message.dart';
import 'package:tirta/shared/services/supabase_service.dart';

class ChatLocalDatasource {
  final _uuid = const Uuid();

  Future<String> createSession() async {
    final userId = SupabaseService.currentUser?.id;
    final response = await SupabaseService.client
        .from('chat_sessions')
        .insert({
          'user_id': userId,
          'title': 'Sesi Chat Baru',
        })
        .select()
        .single();

    return response['id'] as String;
  }

  Future<List<ChatMessage>> getMessages(String sessionId) async {
    final response = await SupabaseService.client
        .from('chat_messages')
        .select()
        .eq('session_id', sessionId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => ChatMessageModel.fromJson(json).toEntity())
        .toList();
  }

  Future<ChatMessage> saveMessage(ChatMessage message) async {
    final model = ChatMessageModel.fromEntity(message);
    final json = model.toJson();

    if (message.id == null) {
      json['id'] = _uuid.v4();
    }

    final response = await SupabaseService.client
        .from('chat_messages')
        .insert(json)
        .select()
        .single();

    return ChatMessageModel.fromJson(response).toEntity();
  }

  Future<String?> getLatestSession() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return null;

    final response = await SupabaseService.client
        .from('chat_sessions')
        .select('id')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1);

    if (response.isNotEmpty) {
      return response.first['id'] as String;
    }
    return null;
  }
}
