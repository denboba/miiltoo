class Message {
  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;

  Message({required this.id, required this.senderId, required this.text, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'text': text,
        'createdAt': createdAt.toUtc(),
      };

  factory Message.fromMap(String id, Map<String, dynamic> map) => Message(
        id: id,
        senderId: map['senderId'] as String? ?? '',
        text: map['text'] as String? ?? '',
        createdAt: (map['createdAt'] as DateTime?) ?? DateTime.parse(map['createdAt'].toString()),
      );
}

