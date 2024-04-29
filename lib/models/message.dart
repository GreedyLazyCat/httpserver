import 'dart:convert';

class Message {
  final String chatroomId;
  final String authorId;
  final String body;

  Message(
      {required this.chatroomId, required this.authorId, required this.body});

  String toJson() {
    return jsonEncode({
      'chatroom_id': chatroomId,
      'author_id': authorId,
      'body': body
    });
  }
}
