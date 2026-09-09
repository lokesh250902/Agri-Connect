import 'package:flutter/material.dart';
class VoiceButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onPressed;
  const VoiceButton({super.key, required this.isRecording, required this.onPressed});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onPressed, child: AnimatedContainer(
    duration: const Duration(milliseconds: 250), width: isRecording ? 100 : 84, height: isRecording ? 100 : 84,
    decoration: BoxDecoration(shape: BoxShape.circle, color: isRecording ? Colors.red : Colors.deepPurple, boxShadow: [BoxShadow(blurRadius: isRecording ? 25 : 12, spreadRadius: isRecording ? 5 : 1, color: (isRecording ? Colors.red : Colors.deepPurple).withValues(alpha: 0.3))]),
    child: Icon(isRecording ? Icons.stop : Icons.mic, color: Colors.white, size: 38),
  ));
}
