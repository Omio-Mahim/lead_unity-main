class ChatMessage {
  final String id;
  final String content;
  final bool isUserMessage; // true = user, false = bot
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUserMessage,
    required this.timestamp,
  });

  // Factory constructor to create from API response
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] as String,
      content: json['content'] as String,
      isUserMessage: json['isUserMessage'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  // Convert to JSON for sending to API
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'isUserMessage': isUserMessage,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
