class ChatMessage {
  final String content;
  final String idFrom;
  final String idTo;
  final int timestamp;

  ChatMessage({
    required this.content,
    required this.idFrom,
    required this.idTo,
    required this.timestamp,
  });

  factory ChatMessage.fromMap(Map<dynamic, dynamic> map) {
    return ChatMessage(
      content: map['content'],
      idFrom: map['idFrom'],
      idTo: map['idTo'],
      timestamp: map['timestamp'],
    );
  }

  Map<String, dynamic> toJson() => {
        "content": content,
        "idFrom": idFrom,
        "idTo": idTo,
        "timestamp": timestamp,
      };
}
