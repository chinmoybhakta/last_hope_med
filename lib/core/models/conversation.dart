import 'package:last_hope_med/core/models/chat_message.dart';

class Conversation {
  final String id;
  String title;
  final List<LocalChatMessage> messages;
  final DateTime createdAt;
  DateTime updatedAt;

  Conversation({
    required this.id,
    required this.title,
    List<LocalChatMessage >? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : messages = messages ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  void addMessage(LocalChatMessage  message) {
    messages.add(message);
    updatedAt = DateTime.now();
    if (messages.length == 2 && title == 'New Conversation') {
      title = message.content.length > 50
          ? '${message.content.substring(0, 50)}...'
          : message.content;
    }
  }

  // Convert to Map for Hive storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // FIXED: Properly handle dynamic map from Hive
  factory Conversation.fromMap(Map map) {
    final messagesList = (map['messages'] as List?) ?? [];
    
    return Conversation(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'New Conversation',
      messages: messagesList
          .map((m) => LocalChatMessage.fromMap(Map<String, dynamic>.from(m)))
          .toList(),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(int.tryParse(map['createdAt'].toString()) ?? 0)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(int.tryParse(map['updatedAt'].toString()) ?? 0)
          : DateTime.now(),
    );
  }
}