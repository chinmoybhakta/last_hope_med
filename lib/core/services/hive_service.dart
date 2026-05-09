import 'dart:developer';
import 'package:hive/hive.dart';
import '../models/conversation.dart';
import '../models/chat_message.dart';

class HiveService {
  static const String _boxName = 'conversations';
  
  // Singleton pattern
  static final HiveService instance = HiveService._();
  HiveService._();
  
  Box? _box;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
    _isInitialized = true;
  }

  bool get isInitialized => _isInitialized;

  Box get _safeBox {
    if (_box == null) {
      throw StateError('HiveService not initialized. Call init() first.');
    }
    return _box!;
  }

  List<Conversation> getAllConversations() {
    final conversations = <Conversation>[];
    for (var key in _safeBox.keys) {
      final data = _safeBox.get(key);
      if (data != null) {
        try {
          conversations.add(Conversation.fromMap(Map.from(data)));
        } catch (e) {
          log('Error loading conversation $key: $e');
        }
      }
    }
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return conversations;
  }

  Conversation? getConversation(String id) {
    final data = _safeBox.get(id);
    if (data != null) {
      try {
        return Conversation.fromMap(Map.from(data));
      } catch (e) {
        log('Error loading conversation: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> saveConversation(Conversation conversation) async {
    await _safeBox.put(conversation.id, conversation.toMap());
  }

  Future<void> deleteConversation(String id) async {
    await _safeBox.delete(id);
  }

  Future<void> addMessageToConversation(
    String conversationId,
    LocalChatMessage message,
  ) async {
    final conversation = getConversation(conversationId);
    if (conversation != null) {
      conversation.addMessage(message);
      await saveConversation(conversation);
    }
  }

  String createNewConversation() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final conversation = Conversation(id: id, title: 'New Conversation');
    _safeBox.put(id, conversation.toMap());
    return id;
  }
}