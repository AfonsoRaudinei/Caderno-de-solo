import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class ImageSourceResolver {
  static ImageProvider<Object>? imageProvider(String? source) {
    final value = _normalized(source);
    if (value == null) return null;
    if (_isRemote(value)) return NetworkImage(value);
    if (_isDataUri(value)) {
      final bytes = _bytesFromDataUri(value);
      return bytes == null ? null : MemoryImage(bytes);
    }

    final path = _localPath(value);
    if (path == null) return null;
    final file = File(path);
    if (!file.existsSync()) return null;
    return FileImage(file);
  }

  static Future<Uint8List?> loadBytes(String? source) async {
    final value = _normalized(source);
    if (value == null) return null;
    if (_isDataUri(value)) return _bytesFromDataUri(value);
    if (_isRemote(value)) return _loadRemoteBytes(value);

    final path = _localPath(value);
    if (path == null) return null;
    final file = File(path);
    if (!await file.exists()) return null;
    return Uint8List.fromList(await file.readAsBytes());
  }

  static Future<String?> toDataUri(String? source) async {
    final value = _normalized(source);
    if (value == null) return null;
    if (_isDataUri(value)) return value;

    final bytes = await loadBytes(value);
    if (bytes == null || bytes.isEmpty) return null;
    final mime = _guessMimeType(value, bytes);
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }

  static String? localPath(String? source) {
    final value = _normalized(source);
    if (value == null || _isRemote(value) || _isDataUri(value)) return null;
    return _localPath(value);
  }

  static String? _normalized(String? source) {
    final trimmed = source?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  static bool _isRemote(String source) {
    return source.startsWith('http://') || source.startsWith('https://');
  }

  static bool _isDataUri(String source) {
    return source.startsWith('data:');
  }

  static String? _localPath(String source) {
    if (source.startsWith('file://')) {
      try {
        return Uri.parse(source).toFilePath();
      } catch (_) {
        return null;
      }
    }
    return source;
  }

  static Uint8List? _bytesFromDataUri(String dataUri) {
    final commaIndex = dataUri.indexOf(',');
    if (commaIndex <= 0 || commaIndex == dataUri.length - 1) return null;
    try {
      return Uint8List.fromList(
          base64Decode(dataUri.substring(commaIndex + 1)));
    } catch (_) {
      return null;
    }
  }

  static Future<Uint8List?> _loadRemoteBytes(String source) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(source));
      final response = await request.close();
      if (response.statusCode != 200) return null;
      return Uint8List.fromList(
        await consolidateHttpClientResponseBytes(response),
      );
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }

  static String _guessMimeType(String source, Uint8List bytes) {
    final lower = source.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    if (lower.endsWith('.heif')) return 'image/heif';
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    return 'image/png';
  }
}
