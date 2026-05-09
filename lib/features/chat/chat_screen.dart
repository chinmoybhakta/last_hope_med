// lib/features/chat/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:last_hope_med/core/services/llama_service.dart';
import 'package:last_hope_med/features/widgets/chat_bubble.dart';
import 'package:last_hope_med/features/widgets/empty_state.dart';
import 'package:last_hope_med/features/widgets/error_card.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/providers/service_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Store reference to LlamaService early (while widget is alive)
  late final LlamaService _llamaService;

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    ref.read(chatProvider(widget.conversationId).notifier).sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    _llamaService = ref.read(llamaServiceProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider(widget.conversationId));

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Unload model when leaving chat screen
          ref.read(llamaServiceProvider).unloadModel();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Qwen-MediCare-BD'),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Unload model before navigating back
              _llamaService.unloadModel();  // Use stored reference
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Column(
          children: [
            // Error display
            if (state.error != null)
              ErrorCard(message: state.error!, onRetry: () {}),

            // Chat messages
            Expanded(
              child: state.messages.isEmpty
                  ? EmptyState(
                      icon: Icons.medical_services,
                      title: 'Ask a medical question',
                      subtitle: 'Get answers in both English and Bangla',
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        return ChatBubble(
                          message: state.messages[index],
                          index: index,
                          isGenerating:
                              state.isLoading &&
                              index == state.messages.length - 1,
                          onDelete: (idx) {
                            ref
                                .read(
                                  chatProvider(widget.conversationId).notifier,
                                )
                                .deleteMessageAtIndex(idx);
                          },
                          onEdit: (idx, newContent) {
                            ref
                                .read(
                                  chatProvider(widget.conversationId).notifier,
                                )
                                .editMessageAtIndex(idx, newContent);
                          },
                        );
                      },
                    ),
            ),

            // Loading indicator
            if (state.isLoading) const LinearProgressIndicator(),

            // Input field
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    final state = ref.watch(chatProvider(widget.conversationId));

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Type your question...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                enabled: !state.isLoading,
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              onPressed: state.isLoading ? null : _sendMessage,
              mini: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              child: state.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();

    _llamaService.unloadModel();

    super.dispose();
  }
}
