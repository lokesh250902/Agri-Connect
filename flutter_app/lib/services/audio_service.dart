import 'package:record/record.dart';
class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  Future<bool> requestPermission() => _recorder.hasPermission();
  Future<void> startRecording(String path) async {
    if (!await _recorder.hasPermission()) throw Exception('Microphone permission was denied.');
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc, sampleRate: 44100, numChannels: 1, bitRate: 128000), path: path);
  }
  Future<String?> stopRecording() => _recorder.stop();
  Future<void> dispose() => _recorder.dispose();
}
