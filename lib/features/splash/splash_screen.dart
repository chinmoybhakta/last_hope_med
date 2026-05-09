import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:last_hope_med/core/utils/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '../onboarding/onboarding_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _status = 'Checking models...';
  final OnDeviceTranslatorModelManager _modelManager = OnDeviceTranslatorModelManager();

  @override
  void initState() {
    super.initState();
    _checkAllModels();
  }

  Future<void> _checkAllModels() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      
      // Check GGUF model
      setState(() => _status = 'Checking AI model...');
      final modelPath = '${dir.path}/models/${AppConstants.modelFileName}';
      final modelFile = File(modelPath);
      bool ggufValid = false;
      
      if (modelFile.existsSync()) {
        final size = modelFile.lengthSync();
        if (size >= 1500000000) { // 1.5 GB minimum
          ggufValid = true;
          log('✅ GGUF model valid: ${_formatBytes(size)}');
        } else {
          log('❌ GGUF incomplete (${_formatBytes(size)}), deleting...');
          modelFile.deleteSync();
        }
      } else {
        log('❌ GGUF model not found');
      }

      // Check translation models using ML Kit's own API
      setState(() => _status = 'Checking language models...');
      
      bool bnValid = false;
      bool enValid = false;
      
      try {
        // Use ML Kit's model manager to check - this is the CORRECT way
        bnValid = await _modelManager.isModelDownloaded('bn');
        enValid = await _modelManager.isModelDownloaded('en');
        
        log('ML Kit check - BN: $bnValid, EN: $enValid');
      } catch (e) {
        log('ML Kit check failed: $e');
        
        // Fallback: check the no_backup directory where ML Kit actually stores models
        final noBackupDir = Directory('${dir.path}/../no_backup/com.google.mlkit.translate.models');
        if (noBackupDir.existsSync()) {
          final bnDir = Directory('${noBackupDir.path}/bn_en');
          bnValid = bnDir.existsSync() && bnDir.listSync().isNotEmpty;
          
          final enDir = Directory('${noBackupDir.path}/en_bn');
          enValid = enDir.existsSync() && enDir.listSync().isNotEmpty;
          
          log('Fallback check - BN: $bnValid, EN: $enValid');
        }
      }

      if (!mounted) return;
      
      setState(() => _status = 'Starting app...');
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      
      if (ggufValid && bnValid && enValid) {
        log('All models ready → Home');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        log('Models missing → Onboarding (GGUF: $ggufValid, BN: $bnValid, EN: $enValid)');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    } catch (e) {
      log('Error checking models: $e');
      if (!mounted) return;
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.medical_services, size: 80, color: Colors.white),
            const SizedBox(height: 24),
            const Text(
              'Qwen-MediCare-BD',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'স্বাস্থ্য আপনার হাতের মুঠোয়',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(_status, style: const TextStyle(fontSize: 13, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}