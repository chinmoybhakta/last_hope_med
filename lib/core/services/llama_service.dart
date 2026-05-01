import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:llama_flutter_android/llama_flutter_android.dart';

class LlamaService {
  static final LlamaService instance = LlamaService._();
  LlamaService._();
  
  LlamaController? _controller;
  bool _isLoaded = false;
  StreamSubscription<String>? _subscription;
  String? _loadedModelPath;

  bool get isLoaded => _isLoaded;

  /// Unload model and free native resources
  Future<void> unloadModel() async {
    log('🔵 [LlamaService] ========== UNLOADING MODEL ==========');
    
    if (!_isLoaded && _controller == null) {
      log('🟡 [LlamaService] Nothing to unload');
      return;
    }
    
    try {
      // Stop any ongoing generation
      _subscription?.cancel();
      _subscription = null;
      
      // Dispose the controller (this frees native resources)
      if (_controller != null) {
        log('🔵 [LlamaService] Disposing LlamaController...');
        _controller!.dispose();
        _controller = null;
        log('🟢 [LlamaService] Controller disposed');
      }
      
      _isLoaded = false;
      _loadedModelPath = null;
      
      // Small delay to let native side clean up
      await Future.delayed(const Duration(milliseconds: 200));
      
      log('🟢 [LlamaService] ✅ Model unloaded completely');
      log('🟢 [LlamaService] ====================================');
    } catch (e) {
      log('🔴 [LlamaService] Error unloading: $e');
      // Force reset even on error
      _controller = null;
      _isLoaded = false;
      _loadedModelPath = null;
    }
  }

  Future<bool> loadModel(String modelPath) async {
    log('🔵 [LlamaService] ========== LOADING MODEL ==========');
    log('🔵 [LlamaService] Path: $modelPath');
    log('🔵 [LlamaService] Currently loaded: $_isLoaded');
    
    // If already loaded with same path, reuse
    if (_isLoaded && _loadedModelPath == modelPath && _controller != null) {
      log('🟢 [LlamaService] Already loaded from same path');
      return true;
    }
    
    // Always unload first to start fresh
    if (_isLoaded || _controller != null) {
      log('🟡 [LlamaService] Unloading before reload...');
      await unloadModel();
    }
    
    try {
      final file = File(modelPath);
      
      if (!file.existsSync()) {
        log('🔴 [LlamaService] File not found: $modelPath');
        return false;
      }
      
      final size = file.lengthSync();
      if (size < 1000000000) {
        log('🔴 [LlamaService] File too small: ${_formatBytes(size)}');
        return false;
      }
      
      log('🔵 [LlamaService] File size: ${_formatBytes(size)}');
      log('🔵 [LlamaService] Creating new LlamaController...');
      
      _controller = LlamaController();
      
      await _controller!.loadModel(
        modelPath: modelPath,
        threads: 4,
        contextSize: 2048,
      );
      
      _isLoaded = true;
      _loadedModelPath = modelPath;
      log('🟢 [LlamaService] ✅ Model loaded successfully!');
      return true;
      
    } catch (e) {
      log('🔴 [LlamaService] Error: $e');
      
      // If "already loaded" error, treat as success (native layer has it)
      if (e.toString().contains('already loaded') || 
          e.toString().contains('Bad state')) {
        log('🟡 [LlamaService] Native says loaded, marking as loaded');
        _isLoaded = true;
        _loadedModelPath = modelPath;
        return true;
      }
      
      _controller?.dispose();
      _controller = null;
      _isLoaded = false;
      _loadedModelPath = null;
      return false;
    }
  }

  Future<String> generateResponse(String prompt) async {
    if (!_isLoaded || _controller == null) {
      log('🔴 [LlamaService] Not loaded!');
      return 'Model not loaded. Please restart the app.';
    }

    try {
      final buffer = StringBuffer();
      
      final stream = _controller!.generate(
        prompt: prompt,
        temperature: 0.8,
        topP: 0.95,
        topK: 40,
        repeatPenalty: 1.1,
        frequencyPenalty: 0.1,
        presencePenalty: 0.1,
        penalizeNewline: false,
      );

      await for (final token in stream) {
        buffer.write(token);
      }

      String response = buffer.toString();
      response = response.replaceAll('<|im_end|>', '');
      response = response.replaceAll('<|endoftext|>', '');
      
      log('🟢 [LlamaService] Generated: ${response.length} chars');
      return response;
      
    } catch (e) {
      log('🔴 [LlamaService] Generate error: $e');
      _isLoaded = false;
      return 'Error generating response';
    }
  }

  Stream<String> generateStream(String prompt) async* {
    if (!_isLoaded || _controller == null) {
      yield 'Model not loaded';
      return;
    }

    final stream = _controller!.generate(
      prompt: prompt,
      temperature: 0.7,
      topP: 0.9,
    );

    await for (final token in stream) {
      yield token;
    }
  }

  void dispose() {
    log('🔵 [LlamaService] Full dispose...');
    _subscription?.cancel();
    _subscription = null;
    _controller?.dispose();
    _controller = null;
    _isLoaded = false;
    _loadedModelPath = null;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}