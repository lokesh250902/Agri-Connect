import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/voice_button.dart';

class HomeScreen extends StatefulWidget { const HomeScreen({super.key}); @override State<HomeScreen> createState() => _HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> {
  final AudioService _audioService = AudioService();
  final ApiService _apiService = ApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<ChatMessage> _messages = [];
  bool _isRecording = false, _isProcessing = false;
  @override void dispose() { _audioService.dispose(); _audioPlayer.dispose(); super.dispose(); }
  Future<String> _getAudioPath() async { final directory = await getTemporaryDirectory(); return '${directory.path}/voice_input.m4a'; }
  Future<void> _toggleRecording() async { if (_isProcessing) return; if (_isRecording) await _stopRecording(); else await _startRecording(); }
  Future<void> _startRecording() async { try { if (!await _audioService.requestPermission()) { _showError('Microphone permission is required.'); return; } await _audioService.startRecording(await _getAudioPath()); setState(() => _isRecording = true); } catch (e) { _showError(e.toString()); } }
  Future<void> _stopRecording() async { try { final path = await _audioService.stopRecording(); setState(() => _isRecording = false); if (path == null) { _showError('Recording failed.'); return; } await _processAudio(path); } catch (e) { setState(() => _isRecording = false); _showError(e.toString()); } }
  Future<void> _processAudio(String path) async { setState(() => _isProcessing = true); try { final response = await _apiService.sendVoice(path); setState(() { _messages.add(ChatMessage(text: response.transcript, type: MessageType.user, language: response.language)); _messages.add(ChatMessage(text: response.answer, type: MessageType.assistant, language: response.language)); }); await _playAudio(response.audioBytes); } catch (e) { _showError(e.toString()); } finally { if (mounted) setState(() => _isProcessing = false); } }
  Future<void> _playAudio(Uint8List bytes) async { await _audioPlayer.stop(); await _audioPlayer.play(BytesSource(bytes, mimeType: 'audio/wav')); }
  void _showError(String message) { if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red)); }
  void _clearChat() => setState(() => _messages.clear());
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Row(children: [Icon(Icons.smart_toy), SizedBox(width: 10), Text('Voice AI Assistant')]), actions: [IconButton(onPressed: _messages.isEmpty ? null : _clearChat, icon: const Icon(Icons.delete_outline))]),
    body: Column(children: [Expanded(child: _messages.isEmpty ? _buildWelcome() : ListView.builder(padding: const EdgeInsets.only(top: 12, bottom: 20), itemCount: _messages.length, itemBuilder: (context, index) => ChatBubble(message: _messages[index]))), if (_isProcessing) const Padding(padding: EdgeInsets.only(bottom: 12), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 10), Text('Thinking...')])), Container(width: double.infinity, padding: const EdgeInsets.fromLTRB(20, 15, 20, 30), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))), child: Column(children: [Text(_isRecording ? 'Listening...' : _isProcessing ? 'Processing...' : 'Tap the microphone and speak', style: const TextStyle(fontSize: 15, color: Colors.black54)), const SizedBox(height: 15), VoiceButton(isRecording: _isRecording, onPressed: _toggleRecording)]))]),
  );
  Widget _buildWelcome() => Center(child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 110, height: 110, decoration: BoxDecoration(color: Colors.deepPurple.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.graphic_eq, size: 55, color: Colors.deepPurple)), const SizedBox(height: 25), const Text('Voice AI Assistant', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)), const SizedBox(height: 12), const Text('Speak in your language.\nI will understand and answer you.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5)), const SizedBox(height: 25), const Text('English • தமிழ் • हिन्दी • తెలుగు • ಕನ್ನಡ • മലയാളം', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black45))])));
}
