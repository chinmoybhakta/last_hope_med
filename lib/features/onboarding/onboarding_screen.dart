import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:last_hope_med/core/utils/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  bool _isDownloading = false;
  double _progress = 0.0;
  String _status = '';
  String? _error;
  final OnDeviceTranslatorModelManager _modelManager =
      OnDeviceTranslatorModelManager();

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation (scale up/down)
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotate animation for the icon
    _rotateController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.linear));

    // Auto-start download after a brief delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _downloadModels();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _downloadModels() async {
    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _error = null;
      _status = 'Preparing download';
    });

    WakelockPlus.enable();

    try {
      final dir = await getApplicationDocumentsDirectory();

      // Step 1: Download GGUF model (0-80%)
      setState(() => _status = 'Downloading AI model');
      await _downloadGGUF(dir);

      // Step 2: Download Bengali translation (80-90%)
      setState(() {
        _progress = 0.8;
        _status = 'Downloading Bengali language pack';
      });
      await _downloadTranslationModel('bn');

      // Step 3: Download English translation (90-100%)
      setState(() {
        _progress = 0.9;
        _status = 'Downloading English language pack';
      });
      await _downloadTranslationModel('en');

      setState(() {
        _progress = 1.0;
        _status = 'All models ready! Starting app';
      });

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      setState(() {
        _error = e.toString();
        _status = 'Download failed';
      });
    } finally {
      setState(() => _isDownloading = false);
      WakelockPlus.disable();
    }
  }

  Future<void> _downloadGGUF(Directory dir) async {
    final modelDir = Directory('${dir.path}/models');
    if (!modelDir.existsSync()) {
      modelDir.createSync(recursive: true);
    }

    final filePath = '${modelDir.path}/${AppConstants.modelFileName}';
    final tempPath = '$filePath.temp';
    final file = File(filePath);
    final tempFile = File(tempPath);

    if (file.existsSync() && file.lengthSync() >= 1500000000) {
      log('GGUF model already exists');
      return;
    }

    int startByte = 0;
    if (tempFile.existsSync()) {
      startByte = tempFile.lengthSync();
      if (startByte > 0) {
        setState(() => _status = 'Resuming previous download');
      }
    }

    final client = http.Client();
    final request = http.Request('GET', Uri.parse(AppConstants.hfDownloadUrl));

    if (startByte > 0) {
      request.headers['Range'] = 'bytes=$startByte-';
    }

    final response = await client.send(request);
    final totalBytes = (response.contentLength ?? 0) + startByte;
    var downloadedBytes = startByte;

    final sink = tempFile.openWrite(
      mode: startByte > 0 ? FileMode.append : FileMode.write,
    );

    await for (final chunk in response.stream) {
      sink.add(chunk);
      downloadedBytes += chunk.length;

      if (totalBytes > 0) {
        setState(() => _progress = (downloadedBytes / totalBytes) * 0.8);
      }
    }

    await sink.close();
    client.close();

    if (tempFile.existsSync()) {
      tempFile.renameSync(filePath);
    }
  }

  Future<void> _downloadTranslationModel(String languageCode) async {
    final isDownloaded = await _modelManager.isModelDownloaded(languageCode);
    if (isDownloaded) {
      log('Translation model $languageCode already exists');
      return;
    }
    await _modelManager.downloadModel(languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Spacer(),
              // Animated illustration area
              _buildAnimatedIllustration(theme),
                  
              // Subtitle
              Text(
                _isDownloading
                    ? 'Please wait while we prepare your medical assistant'
                    : 'Downloading AI model and language packs\nfor offline use (~2GB)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              Spacer(),
              // Progress section
              if (_isDownloading) _buildProgressSection(theme),
                  
              // Error section
              if (_error != null && !_isDownloading)
                _buildErrorSection(theme),
                  
              // Manual download button (only shown if download hasn't started)
              if (!_isDownloading && _error != null) _buildRetryButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIllustration(ThemeData theme) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotateController]),
      builder: (context, child) {
        return Column(
          children: [
            // Main icon with pulse and rotate
            Transform.scale(
              scale: _isDownloading ? _pulseAnimation.value : 1.0,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                      theme.colorScheme.secondary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.medical_services,
                  size: 56,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Orbiting dots (only during download)
            if (_isDownloading)
              SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final delay = index * 0.2;
                    return _buildOrbitingDot(
                      theme,
                      index,
                      _rotateAnimation.value + delay,
                    );
                  }),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildOrbitingDot(ThemeData theme, int index, double position) {
    final colors = [
      theme.colorScheme.primary,
      Colors.blue,
      Colors.teal,
      theme.colorScheme.secondary,
      Colors.green,
    ];

    final opacity = ((position * 2 + index * 0.2) % 1.0).clamp(0.3, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: colors[index % colors.length].withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildProgressSection(ThemeData theme) {
    return Column(
      children: [
        // Row with status and percentage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Status message with animated dots
            _buildStatusWithDots(),
            Spacer(),
            // Percentage
            Text(
              '${(_progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 10,
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Size info
        Text(
          '~2 GB download required',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildStatusWithDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _status,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          textAlign: TextAlign.start,
        ),
        const SizedBox(width: 4),
        _AnimatedDots(),
      ],
    );
  }

  Widget _buildErrorSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off, size: 48, color: Colors.red[400]),
          const SizedBox(height: 12),
          Text(
            'Download Failed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your internet connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[600], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildRetryButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: ElevatedButton.icon(
        onPressed: _downloadModels,
        icon: const Icon(Icons.refresh),
        label: const Text('Retry Download'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(220, 52),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

/// Animated dots widget for showing loading state
class _AnimatedDots extends StatefulWidget {
  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dotCount = (_controller.value * 4).floor();
        return Text(
          '.' * dotCount,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        );
      },
    );
  }
}
