import 'package:flutter_riverpod/legacy.dart';
import 'package:last_hope_med/core/providers/service_providers.dart';
import 'package:last_hope_med/core/services/hive_service.dart';
import '../models/conversation.dart';

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return HomeNotifier(hiveService);
});

class HomeState {
  final List<Conversation> conversations;
  final bool isLoading;

  const HomeState({
    this.conversations = const [],
    this.isLoading = false,
  });
}

class HomeNotifier extends StateNotifier<HomeState> {
  final HiveService _hiveService;

  HomeNotifier(this._hiveService) : super(const HomeState()) {
    // No need to call init() - already initialized in main
    loadConversations();
  }

  Future<void> loadConversations() async {
    final conversations = _hiveService.getAllConversations();
    state = HomeState(conversations: conversations);
  }

  Future<String> createNewConversation() async {
    final id = _hiveService.createNewConversation();
    await loadConversations();
    return id;
  }

  Future<void> deleteConversation(String id) async {
    await _hiveService.deleteConversation(id);
    await loadConversations();
  }
}