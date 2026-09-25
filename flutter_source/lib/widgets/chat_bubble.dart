import 'package:flutter/material.dart';
import '../models/chat_message.dart';
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});
  @override Widget build(BuildContext context) {
    final user = message.type == MessageType.user;
    return Align(alignment: user ? Alignment.centerRight : Alignment.centerLeft, child: Container(
      constraints: const BoxConstraints(maxWidth: 340), margin: const EdgeInsets.all(8), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: user ? Colors.green : Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (!user && message.language != null) Text(message.language!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
        Text(message.text, style: TextStyle(color: user ? Colors.white : Colors.black87, fontSize: 16, height: 1.35)),
      ]),
    ));
  }
}
