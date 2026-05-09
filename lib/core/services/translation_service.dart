import 'dart:developer';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  final Map<String, OnDeviceTranslator> _translators = {};
  final OnDeviceTranslatorModelManager _modelManager = OnDeviceTranslatorModelManager();

  Future<bool> isModelDownloaded(String languageCode) async {
    try {
      return await _modelManager.isModelDownloaded(languageCode);
    } catch (e) {
      return false;
    }
  }

  Future<bool> ensureModelDownloaded(String languageCode) async {
    try {
      final isDownloaded = await _modelManager.isModelDownloaded(languageCode);
      if (!isDownloaded) {
        await _modelManager.downloadModel(languageCode);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> translate(String text, String sourceLang, String targetLang) async {
    if (text.isEmpty) return text;
    
    log('🔄 [Translate] $sourceLang→$targetLang: "${text.length > 100 ? '${text.substring(0, 100)}...' : text}"');
    
    try {
      final source = _getLanguageFromCode(sourceLang);
      final target = _getLanguageFromCode(targetLang);
      
      if (source == null || target == null) {
        log('🔴 [Translate] Invalid language code');
        return text;
      }
      
      // Use unique key for each direction
      final key = '$sourceLang-$targetLang';
      
      // Create or reuse translator for this specific direction
      if (!_translators.containsKey(key)) {
        log('🔄 [Translate] Creating translator: $key');
        _translators[key] = OnDeviceTranslator(
          sourceLanguage: source,
          targetLanguage: target,
        );
      }
      
      final translator = _translators[key]!;
      final result = await translator.translateText(text.trim());
      
      log('🔄 [Translate] RESULT ($key): "${result.length > 100 ? '${result.substring(0, 100)}...' : result}"');
      
      return result;
    } catch (e) {
      log('🔴 [Translate] Error: $e');
      return text;
    }
  }

  Future<String> banglaToEnglish(String banglaText) async {
    return await translate(banglaText, 'bn', 'en');
  }

  Future<String> englishToBangla(String englishText) async {
    return await translate(englishText, 'en', 'bn');
  }

  TranslateLanguage? _getLanguageFromCode(String code) {
    switch (code) {
      case 'bn':
        return TranslateLanguage.bengali;
      case 'en':
        return TranslateLanguage.english;
      default:
        return null;
    }
  }

  void dispose() {
    for (final translator in _translators.values) {
      translator.close();
    }
    _translators.clear();
  }
}