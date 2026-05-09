// lib/features/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:last_hope_med/features/home/about_screen.dart';
import 'package:last_hope_med/features/widgets/conversation_tile.dart';
import 'package:last_hope_med/features/widgets/empty_state.dart';
import '../../core/providers/home_provider.dart';
import '../chat/chat_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AboutScreen()),
            ),
            icon: Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: state.conversations.isEmpty
          ? EmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'No conversations yet',
              subtitle: 'Start a new medical consultation',
              onAction: () async {
                final id = await ref
                    .read(homeProvider.notifier)
                    .createNewConversation();
                if (!context.mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(conversationId: id),
                  ),
                );
              },
              actionLabel: 'New Conversation',
            )
          : ListView.builder(
              itemCount: state.conversations.length,
              itemBuilder: (context, index) {
                final conversation = state.conversations[index];
                return ConversationTile(
                  conversation: conversation,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ChatScreen(conversationId: conversation.id),
                      ),
                    );
                  },
                  onDelete: () {
                    ref
                        .read(homeProvider.notifier)
                        .deleteConversation(conversation.id);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final id = await ref
              .read(homeProvider.notifier)
              .createNewConversation();
          if (!context.mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ChatScreen(conversationId: id)),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
