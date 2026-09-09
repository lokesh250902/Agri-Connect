import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
class VoiceResponse {
  final String transcript, language, languageCode, answer;
  final Uint8List audioBytes;
  VoiceResponse({required this.transcript, required this.language, required this.languageCode, required this.answer, required this.audioBytes});
}
class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  Future<VoiceResponse> sendVoice(String audioPath) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/voice'));
    request.files.add(await http.MultipartFile.fromPath('audio', audioPath));
    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 200) {
      String message = 'Server error: ${response.statusCode}';
      try { final data = jsonDecode(response.body); message = data['detail']?.toString() ?? message; } catch (_) {}
      throw Exception(message);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return VoiceResponse(
      transcript: data['transcript'] ?? '', language: data['language'] ?? 'Unknown', languageCode: data['language_code'] ?? '', answer: data['answer'] ?? '', audioBytes: base64Decode(data['audio_base64']),
    );
  }
}
