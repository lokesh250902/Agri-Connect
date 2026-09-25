import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';
import 'package:record/record.dart';

class AudioService {
  final AudioRecorder recorder = AudioRecorder();
  Future<bool> permission() => recorder.hasPermission();

  // `path` is where the recorder writes on Android/iOS/desktop. On web the
  // record package ignores it and records to an in-memory Blob instead.
  //
  // WAV (not AAC) on purpose: on web, AAC recording depends on the browser's
  // MediaRecorder supporting an AAC/MP4 mime type, which isn't guaranteed
  // (record_web throws "not supported" when it can't find one) and the
  // actual negotiated container isn't exposed back to us to label the
  // upload correctly. record_web encodes WAV itself from raw PCM instead of
  // relying on browser codec support, so it works the same way — and with
  // the same 'audio/wav' content type — on every platform.
  Future<void> start(String path) async {
    if (!await permission()) throw Exception('Microphone permission denied.');
    await recorder.start(const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 44100, numChannels: 1), path: path);
  }

  // Returns the recorded audio as raw bytes. XFile.readAsBytes() reads a
  // real file on Android/iOS/desktop and fetches the Blob on web, so this
  // works the same way on every platform without touching dart:io directly.
  Future<Uint8List?> stop() async {
    final result = await recorder.stop();
    if (result == null) return null;
    return XFile(result).readAsBytes();
  }

  Future<void> dispose() => recorder.dispose();
}
