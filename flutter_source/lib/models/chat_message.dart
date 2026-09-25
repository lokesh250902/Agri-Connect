enum MessageType { user, assistant }
class ChatMessage {
  final String text;
  final MessageType type;
  final String? language;
  ChatMessage({required this.text, required this.type, this.language});
}
