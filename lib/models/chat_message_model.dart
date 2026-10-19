class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final bool isSystem;
  final bool isCorrectGuess;
  final bool isCloseGuess;
  final int timestamp;
  final String? reaction;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.isSystem = false,
    this.isCorrectGuess = false,
    this.isCloseGuess = false,
    required this.timestamp,
    this.reaction,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'isSystem': isSystem,
      'isCorrectGuess': isCorrectGuess,
      'isCloseGuess': isCloseGuess,
      'timestamp': timestamp,
      'reaction': reaction,
    };
  }

  factory ChatMessageModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return ChatMessageModel(
      id: id,
      senderId: (map['senderId'] as String?) ?? '',
      senderName: (map['senderName'] as String?) ?? 'Player',
      text: (map['text'] as String?) ?? '',
      isSystem: (map['isSystem'] as bool?) ?? false,
      isCorrectGuess: (map['isCorrectGuess'] as bool?) ?? false,
      isCloseGuess: (map['isCloseGuess'] as bool?) ?? false,
      timestamp: (map['timestamp'] as num?)?.toInt() ?? 0,
      reaction: map['reaction'] as String?,
    );
  }
}

