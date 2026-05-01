import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../utils/constants.dart';

class HuggingFaceService {
  
  Future<String> downloadModel({
    void Function(double progress)? onProgress,
    void Function(String status)? onStatus,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final modelDir = Directory('${dir.path}/models');
      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }

      final filePath = '${modelDir.path}/${AppConstants.modelFileName}';
      final file = File(filePath);
      final tempPath = '$filePath.temp';

      // Check if complete model already exists
      if (await file.exists()) {
        final size = await file.length();
        if (size > 1000000000) { // > 1GB means valid
          onStatus?.call('Model already downloaded');
          onProgress?.call(1.0);
          return filePath;
        } else {
          // Incomplete file, delete it
          await file.delete();
        }
      }

      // Check for partial download
      final tempFile = File(tempPath);
      int startByte = 0;
      if (await tempFile.exists()) {
        startByte = await tempFile.length();
        onStatus?.call('Resuming download from ${_formatBytes(startByte)}...');
      }

      // Start/resume download
      onStatus?.call('Downloading model...');
      
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(AppConstants.hfDownloadUrl));
      
      if (startByte > 0) {
        request.headers['Range'] = 'bytes=$startByte-';
      }

      final response = await client.send(request);
      final totalBytes = (response.contentLength ?? 0) + startByte;
      var downloadedBytes = startByte;

      // Open file for writing (append if resuming)
      final sink = tempFile.openWrite(
        mode: startByte > 0 ? FileMode.append : FileMode.write,
      );

      await for (final chunk in response.stream) {
        sink.add(chunk);
        downloadedBytes += chunk.length;
        
        if (totalBytes > 0 && onProgress != null) {
          onProgress(downloadedBytes / totalBytes);
        }
      }

      await sink.close();
      client.close();

      // Rename temp to final
      await tempFile.rename(filePath);
      
      onStatus?.call('Download complete');
      return filePath;

    } catch (e) {
      onStatus?.call('Download failed: $e');
      rethrow;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}