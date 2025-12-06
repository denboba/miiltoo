import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final String? senderName;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    DateTime? createdAt,
    this.senderName,
  }) : createdAt = createdAt ?? DateTime.now();

  Message copyWith({
    String? id,
    String? senderId,
    String? text,
    DateTime? createdAt,
    String? senderName,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      senderName: senderName ?? this.senderName,
    );
  }

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'text': text,
        'createdAt': createdAt.toUtc(),
        'senderName': senderName,
      };

  factory Message.fromMap(String id, Map<String, dynamic> map) {
    DateTime parsedCreatedAt;
    final createdAtValue = map['createdAt'];
    if (createdAtValue is DateTime) {
      parsedCreatedAt = createdAtValue;
    } else if (createdAtValue is Timestamp) {
      parsedCreatedAt = createdAtValue.toDate();
    } else if (createdAtValue != null) {
      parsedCreatedAt = DateTime.parse(createdAtValue.toString());
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return Message(
      id: id,
      senderId: map['senderId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      createdAt: parsedCreatedAt,
      senderName: map['senderName'] as String?,
    );
  }
}


