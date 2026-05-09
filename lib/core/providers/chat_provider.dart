import 'dart:developer';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:last_hope_med/core/services/hive_service.dart';
import 'package:last_hope_med/core/services/llama_service.dart';
import 'package:last_hope_med/core/services/translation_service.dart';
import 'package:path_provider/path_provider.dart';
import '../models/chat_message.dart';
import '../utils/constants.dart';
import 'service_providers.dart';

final chatProvider =
    StateNotifierProvider.family<ChatNotifier, ChatState, String>((
      ref,
      conversationId,
    ) {
      final hiveService = ref.read(hiveServiceProvider);
      final llamaService = ref.read(llamaServiceProvider);
      final translationService = ref.read(
        translationServiceProvider,
      ); // ← ADD THIS
      return ChatNotifier(
        conversationId,
        hiveService,
        llamaService,
        translationService,
      ); // ← PASS IT
    });

class ChatState {
  final List<LocalChatMessage> messages;
  final bool isLoading;
  final String? error;
  final bool isModelLoaded;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.isModelLoaded = false,
  });

  ChatState copyWith({
    List<LocalChatMessage>? messages,
    bool? isLoading,
    String? error,
    bool? isModelLoaded,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isModelLoaded: isModelLoaded ?? this.isModelLoaded,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final String conversationId;
  final HiveService _hiveService;
  final LlamaService _llamaService;
  final TranslationService _translationService;
  bool _initialized = false;

  ChatNotifier(
    this.conversationId,
    this._hiveService,
    this._llamaService,
    this._translationService,
  ) : super(const ChatState()) {
    // Use WidgetsBinding to safely call async method after widget is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    // Prevent multiple initializations
    if (_initialized) {
      log('🟡 [ChatProvider] Already initialized, skipping');
      return;
    }
    _initialized = true;

    log('🟡 [ChatProvider] Starting initialization for: $conversationId');
    _loadConversation();
    await _loadLlamaModel();
  }

  Future<void> _loadLlamaModel() async {
    try {
      log('🟡 [ChatProvider] _loadLlamaModel called');

      final dir = await getApplicationDocumentsDirectory();
      final modelPath = '${dir.path}/models/${AppConstants.modelFileName}';

      log('🟡 [ChatProvider] Model path: $modelPath');

      // Check if model already loaded (singleton check)
      log('🟡 [ChatProvider] Singleton isLoaded: ${_llamaService.isLoaded}');

      if (_llamaService.isLoaded) {
        log('🟢 [ChatProvider] Model already loaded in singleton');
        state = state.copyWith(isModelLoaded: true);
        return;
      }

      // Check if model file exists before trying to load
      final modelFile = File(modelPath);
      if (!modelFile.existsSync()) {
        log('🔴 [ChatProvider] Model file not found!');
        state = state.copyWith(error: '🔴 [ChatProvider] Model file not found!');
        return;
      }

      final fileSize = modelFile.lengthSync();
      log('🟡 [ChatProvider] Model file size: $fileSize bytes');

      if (fileSize < 1000000000) {
        log('🔴 [ChatProvider] Model file too small!');
        state = state.copyWith(error: '🔴 [ChatProvider] Model file too small!');
        return;
      }

      log('🟡 [ChatProvider] About to call loadModel...');

      try {
        final loaded = await _llamaService.loadModel(modelPath);
        log('🟡 [ChatProvider] loadModel returned: $loaded');

        if (loaded) {
          log('🟢 [ChatProvider] Model loaded successfully!');
          state = state.copyWith(isModelLoaded: true);
        } else {
          log('🔴 [ChatProvider] loadModel returned false');
          state = state.copyWith(error: '🔴 [ChatProvider] loadModel returned false');
        }
      } catch (loadError, loadStack) {
        log('🔴 [ChatProvider] loadModel threw exception: $loadError');
        log('🔴 [ChatProvider] loadModel stackTrace: $loadStack');
        state = state.copyWith(error: '🔴 [ChatProvider] Error loading model: $loadError');
      }
    } catch (e, stackTrace) {
      log('🔴 [ChatProvider] _loadLlamaModel error: $e');
      log('🔴 [ChatProvider] StackTrace: $stackTrace');
      state = state.copyWith(error: '🔴 [ChatProvider] Error: $e');
    }
  }

  void _loadConversation() {
    final conversation = _hiveService.getConversation(conversationId);
    if (conversation != null) {
      state = ChatState(messages: conversation.messages);
    }
  }

  Future<void> sendMessage(String content) async {
    log('=' * 60);
    log('🟡 [ChatProvider] USER INPUT: "$content"');

    final isBanglaInput = _containsBangla(content);
    log('🟡 [ChatProvider] Is Bangla: $isBanglaInput');

    if (!_llamaService.isLoaded) {
      log('🔴 [ChatProvider] Model not loaded');
      state = state.copyWith(error: '🔴 [ChatProvider] [LlamaService] Not loaded!. Please restart the app.');
      return;
    }

    final userMessage = LocalChatMessage(content: content, isUser: true);
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );
    _hiveService.addMessageToConversation(conversationId, userMessage);

    try {
      // Step 1: Prepare query for model
      String queryForModel = content;

      if (isBanglaInput) {
        log('🔄 [Step 1] BN→EN translating...');
        String translated = await _translationService.banglaToEnglish(content);
        log('🔄 [Step 1] BN→EN: "$translated"');

        // Check if translation is good enough
        if (translated.length < 10 || 
            translated == content ||
            translated.toLowerCase().contains('on fire')) {
          // Poor translation - give model the Bangla with context
          queryForModel = 'The user asked in Bengali: "$content". Please answer this medical question in English.';
          log('🟡 [Step 1] Poor translation, using Bangla with context');
        } else {
          queryForModel = translated;
        }
      }

      // Step 2: Get model response
      final prompt = _buildChatPrompt(queryForModel);
      String modelResponse = await _llamaService.generateResponse(prompt);
      
      // Clean response (removes ChatML tokens, formats bullets)
      modelResponse = _cleanResponse(modelResponse);
      
      // Format disclaimer on new line
      modelResponse = _formatDisclaimer(modelResponse);

      log('🤖 [Step 2] Model: "${modelResponse.length > 200 ? '${modelResponse.substring(0, 200)}...' : modelResponse}"');

      // Step 3: Prepare final response
      String displayResponse;

      if (isBanglaInput) {
        // Simplify for better translation (keep bullets but remove markdown)
        String simplified = modelResponse
            .replaceAll('**', '')
            .replaceAll(RegExp(r'#{1,6}\s*'), '')
            .replaceAll(RegExp(r'\n{3,}'), '\n\n');
        
        log('🔄 [Step 3] EN→BN translating...');
        displayResponse = await _translationService.englishToBangla(simplified);
        
        // Restore newlines lost during translation
        displayResponse = _restoreNewlinesForBangla(displayResponse);
        
        log('🔄 [Step 3] EN→BN: "${displayResponse.length > 200 ? '${displayResponse.substring(0, 200)}...' : displayResponse}"');
      } else {
        displayResponse = modelResponse;
      }

      log('📱 [UI] Final: "${displayResponse.length > 200 ? '${displayResponse.substring(0, 200)}...' : displayResponse}"');

      final assistantMessage = LocalChatMessage(
        content: displayResponse,
        isUser: false,
        translatedContent: isBanglaInput ? modelResponse : null,
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
      );
      _hiveService.addMessageToConversation(conversationId, assistantMessage);
      
    } catch (e) {
      log('🔴 [ChatProvider] Error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }

    log('=' * 60);
  }

  /// Restore newlines and formatting in Bangla text after translation
  String _restoreNewlinesForBangla(String text) {
    // Fix bullet points - add newline before •
    text = text.replaceAllMapped(
      RegExp(r'([।\s])•'),
      (match) => '${match.group(1)}\n•',
    );
    
    // Fix section headers
    text = text
        .replaceAll('মূল তথ্য:', '\nমূল তথ্য:')
        .replaceAll('গুরুত্বপূর্ণ তথ্য:', '\nগুরুত্বপূর্ণ তথ্য:')
        .replaceAll('সতর্কতা:', '\nসতর্কতা:');
    
    // Fix note/disclaimer
    text = text.replaceAllMapped(
      RegExp(r'([।])\s*(নোট:|দ্রষ্টব্য:|দয়া করে মনে রাখবেন:)'),
      (match) => '${match.group(1)}\n\n${match.group(2)}',
    );
    
    // Reduce excessive newlines
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    
    return text.trim();
  }

  /// Ensure disclaimer is on a new line
  String _formatDisclaimer(String text) {
    // If text contains "Note:" but it's not on a separate line, fix it
    if (text.contains('Note:') &&
        !text.contains('\nNote:') &&
        !text.contains('\n\nNote:')) {
      text = text.replaceAllMapped(
        RegExp(r'([.!?])\s*(Note:)', caseSensitive: false),
        (match) => '${match.group(1)}\n\n${match.group(2)}',
      );
    }

    // If text contains "Disclaimer:" but not on separate line
    if (text.contains('Disclaimer:') &&
        !text.contains('\nDisclaimer:') &&
        !text.contains('\n\nDisclaimer:')) {
      text = text.replaceAllMapped(
        RegExp(r'([.!?])\s*(Disclaimer:)', caseSensitive: false),
        (match) => '${match.group(1)}\n\n${match.group(2)}',
      );
    }

    return text;
  }

  String _buildChatPrompt(String userMessage) {
    return '''<|im_start|>system
You are a medical assistant for Bangladesh. Provide detailed, well-structured responses.

FORMAT YOUR RESPONSE EXACTLY LIKE THIS:

[1-2 sentence introduction]

Key Information:
• [Point 1]
• [Point 2]
• [Point 3]

[Additional details if needed]

Note: This information is for educational purposes only. Please consult a qualified healthcare provider for medical advice.<|im_end|>
<|im_start|>user
$userMessage<|im_end|>
<|im_start|>assistant
''';
  }

  String _cleanResponse(String response) {
    log('🧹 [Clean] RAW: "${response.length > 200 ? '${response.substring(0, 200)}...' : response}"');

    String cleaned = response;

    // Extract assistant's response from ChatML format
    if (cleaned.contains('<|im_start|>assistant')) {
      final parts = cleaned.split('<|im_start|>assistant');
      cleaned = parts.last;
    }

    // Remove special tokens
    cleaned = cleaned
        .replaceAll('<|im_end|>', '')
        .replaceAll('<|im_start|>', '')
        .replaceAll('<|endoftext|>', '')
        .trim();

    // Restore bullet point formatting
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'([^\n])•\s*'),
      (match) => '${match.group(1)}\n• ',
    );

    // Ensure "Key Information:" starts on new line only
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'([^\n])(Key Information:)'),
      (match) => '${match.group(1)}\n${match.group(2)}',
    );

    // Reduce excessive newlines (more than 2)
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // Remove leading/trailing whitespace
    cleaned = cleaned.trim();

    log('🧹 [Clean] RESULT (${cleaned.length} chars)');
    return cleaned;
  }

  bool _containsBangla(String text) {
    return RegExp(r'[\u0980-\u09FF]').hasMatch(text);
  }

  /// Delete a specific message and all subsequent messages
  Future<void> deleteMessageAtIndex(int index) async {
    if (index < 0 || index >= state.messages.length) return;
    
    final messages = state.messages.sublist(0, index);
    state = state.copyWith(messages: messages);
    
    // Update in Hive
    final conversation = _hiveService.getConversation(conversationId);
    if (conversation != null) {
      conversation.messages
        ..clear()
        ..addAll(messages);
      await _hiveService.saveConversation(conversation);
    }
  }

  /// Edit a user message and regenerate model response
  Future<void> editMessageAtIndex(int index, String newContent) async {
    if (index < 0 || index >= state.messages.length) return;
    if (!state.messages[index].isUser) return; // Can only edit user messages
    
    if (!_llamaService.isLoaded) {
      state = state.copyWith(error: 'Model not ready.');
      return;
    }

    // Keep messages up to the edited message
    final messages = state.messages.sublist(0, index);
    
    // Add edited user message
    final editedMessage = LocalChatMessage(content: newContent, isUser: true);
    messages.add(editedMessage);
    
    state = state.copyWith(
      messages: messages,
      isLoading: true,
      error: null,
    );

    try {
      // Prepare query for model
      String queryForModel = newContent;
      final isBanglaInput = _containsBangla(newContent);
      
      if (isBanglaInput) {
        queryForModel = await _translationService.banglaToEnglish(newContent);
        if (queryForModel.length < 10 || queryForModel == newContent) {
          queryForModel = 'The user asked in Bengali: "$newContent". Please answer this medical question in English.';
        }
      }

      // Get model response
      final prompt = _buildChatPrompt(queryForModel);
      String modelResponse = await _llamaService.generateResponse(prompt);
      modelResponse = _cleanResponse(modelResponse);
      modelResponse = _formatDisclaimer(modelResponse);

      // Prepare final response
      String displayResponse;
      if (isBanglaInput) {
        String simplified = modelResponse
            .replaceAll('**', '')
            .replaceAll(RegExp(r'#{1,6}\s*'), '')
            .replaceAll(RegExp(r'\n{3,}'), '\n\n');
        
        displayResponse = await _translationService.englishToBangla(simplified);
        displayResponse = _restoreNewlinesForBangla(displayResponse);
      } else {
        displayResponse = modelResponse;
      }

      final assistantMessage = LocalChatMessage(
        content: displayResponse,
        isUser: false,
        translatedContent: isBanglaInput ? modelResponse : null,
      );
      
      messages.add(assistantMessage);
      
      state = state.copyWith(
        messages: messages,
        isLoading: false,
      );
      
      // Save to Hive
      final conversation = _hiveService.getConversation(conversationId);
      if (conversation != null) {
        conversation.messages
          ..clear()
          ..addAll(messages);
        await _hiveService.saveConversation(conversation);
      }
    } catch (e) {
      log('🔴 [ChatProvider] Edit error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  @override
  void dispose() {
    log('🟡 [ChatProvider] Disposing');
    super.dispose();
  }
}
