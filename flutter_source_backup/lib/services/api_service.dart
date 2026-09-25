import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  // 10.0.2.2 only resolves to the host machine from inside the Android
  // emulator. Web, desktop and iOS simulator reach the backend via localhost.
  // Physical devices need the computer's LAN IP set here manually.
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  // MultipartFile.fromBytes defaults to application/octet-stream when no
  // contentType is given, which the backend's mime-type allowlist rejects —
  // so every upload must declare its real content type explicitly.
  Future<Map<String,dynamic>> sendVoice(Uint8List audioBytes, {String filename = 'voice_input.wav', String contentType = 'audio/wav'}) async {
    final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/voice'));
    req.files.add(http.MultipartFile.fromBytes('audio', audioBytes, filename: filename, contentType: MediaType.parse(contentType)));
    final res = await http.Response.fromStream(await req.send());
    return _decode(res);
  }

  Future<Map<String,dynamic>> sendImage(Uint8List imageBytes, String language, {String filename = 'image.jpg', String contentType = 'image/jpeg'}) async {
    final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/image'));
    req.fields['language'] = language;
    req.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: filename, contentType: MediaType.parse(contentType)));
    final res = await http.Response.fromStream(await req.send());
    return _decode(res);
  }

  Future<Map<String,dynamic>> weather(double lat, double lon) async {
    final res = await http.get(Uri.parse('$baseUrl/api/weather?latitude=$lat&longitude=$lon'));
    return _decode(res);
  }

  Map<String,dynamic> _decode(http.Response res) {
    final body = jsonDecode(res.body);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(body is Map ? body['detail'] ?? 'Server error' : 'Server error');
    }
    return Map<String,dynamic>.from(body);
  }

  Uint8List audioBytes(Map<String,dynamic> data) => base64Decode(data['audio_base64']);
}
