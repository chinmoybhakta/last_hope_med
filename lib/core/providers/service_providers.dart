import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hive_service.dart';
import '../services/llama_service.dart';
import '../services/translation_service.dart';
import '../services/connectivity_service.dart';
import '../services/huggingface_service.dart';

// Use singleton instances
final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService.instance;
});

final llamaServiceProvider = Provider<LlamaService>((ref) {
  return LlamaService.instance;  // Singleton
});

// Translation Service Provider
final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService();
});

// Connectivity Service Provider
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

// HuggingFace Service Provider
final huggingFaceServiceProvider = Provider<HuggingFaceService>((ref) {
  return HuggingFaceService();
});