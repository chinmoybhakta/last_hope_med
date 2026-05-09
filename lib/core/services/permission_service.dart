// lib/core/services/permission_service.dart
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request all needed permissions for Android
  Future<bool> requestAllPermissions() async {
    // Storage permission (for Android < 13)
    final storage = await _requestStorage();
    
    // Internet is auto-granted, just check
    final internet = await _checkConnectivity();
    
    return storage && internet;
  }

  Future<bool> _requestStorage() async {
    // For Android 13+ (API 33), no storage permission needed for app-specific directories
    // For older versions, request storage
    if (await Permission.storage.isDenied) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  Future<bool> _checkConnectivity() async {
    return true; // INTERNET permission is auto-granted
  }

  /// Check if storage permission is granted
  Future<bool> isStorageGranted() async {
    return await Permission.storage.isGranted;
  }
}