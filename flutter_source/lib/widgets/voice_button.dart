import 'package:flutter/material.dart';
class VoiceButton extends StatelessWidget {
  final bool recording; final VoidCallback onTap;
  const VoiceButton({super.key, required this.recording, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: CircleAvatar(radius: recording ? 48 : 42, backgroundColor: recording ? Colors.red : Colors.green, child: Icon(recording ? Icons.stop : Icons.mic, color: Colors.white, size: 38)));
}
