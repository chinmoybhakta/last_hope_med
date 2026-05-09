import 'dart:developer';
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:last_hope_med/core/services/hive_service.dart';
import 'package:last_hope_med/features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handler to catch unhandled errors
  FlutterError.onError = (details) {
    log('🔴 [MAIN] FlutterError: ${details.exceptionAsString()}');
    log('🔴 [MAIN] StackTrace: ${details.stack}');
  };

  // Catch isolate errors
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    log('🔴 [MAIN] Platform Error: $error');
    log('🔴 [MAIN] StackTrace: $stackTrace');
    return true;
  };

  await Hive.initFlutter();
  // Initialize HiveService ONCE before app starts
  await HiveService.instance.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qwen-MediCare-BD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0077B6),
          primary: const Color(0xFF0077B6),
          secondary: const Color(0xFF006A4E),
          surface: const Color(0xFFF8F9FA),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
