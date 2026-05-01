class LocalChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? translatedContent;

  LocalChatMessage({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
    this.translatedContent,
  }) : timestamp = timestamp ?? DateTime.now();

  // Create a copy with updated content
  LocalChatMessage copyWith({
    String? content,
    bool? isUser,
    DateTime? timestamp,
    String? translatedContent,
  }) {
    return LocalChatMessage(
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      translatedContent: translatedContent ?? this.translatedContent,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'translatedContent': translatedContent,
    };
  }

  factory LocalChatMessage.fromMap(Map map) {
    return LocalChatMessage(
      content: map['content']?.toString() ?? '',
      isUser: map['isUser'] == true || map['isUser']?.toString() == 'true',
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(int.tryParse(map['timestamp'].toString()) ?? 0)
          : DateTime.now(),
      translatedContent: map['translatedContent']?.toString(),
    );
  }
}