import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String? id;
  final String? sessionId;
  final String role;
  final String content;
  final DateTime? createdAt;

  const ChatMessage({
    this.id,
    this.sessionId,
    required this.role,
    required this.content,
    this.createdAt,
  });

  ChatMessage copyWith({
    String? id,
    String? sessionId,
    String? role,
    String? content,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, sessionId, role, content, createdAt];
}
