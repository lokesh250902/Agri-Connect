import 'package:flutter/material.dart';
import '../models/chat_message.dart';
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});
  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user;
    return Align(alignment: isUser ? Alignment.centerRight : Alignment.centerLeft, child: Container(
      constraints: const BoxConstraints(maxWidth: 330), margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: isUser ? Colors.deepPurple : Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black.withValues(alpha: 0.05))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (message.language != null && !isUser) Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(message.language!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
        Text(message.text, style: TextStyle(fontSize: 16, height: 1.4, color: isUser ? Colors.white : Colors.black87)),
      ]),
    ));
  }
}
