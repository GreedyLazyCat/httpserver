import 'dart:convert';

class Message {
  final String id;
  final String chatroomId;
  final String authorId;
  final String body;

  Message(
      {required this.id,
      required this.chatroomId,
      required this.authorId,
      required this.body});

  String toJson() {
    return jsonEncode({
      'id': id,
      'chatroom_id': chatroomId,
      'author_id': authorId,
      'body': body
    });
  }

  Object toObject() {
    return {'id': id,'chatroom_id': chatroomId, 'author_id': authorId, 'body': body};
  }
}
