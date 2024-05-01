import 'dart:convert';

class Chatroom {
  String id;

  /// [type] = pm - личные сообщения
  /// [type] = group - группа
  String type;
  List<String> participantIds;
  String title;
  String? lastMessageId;

  Chatroom(
      {required this.id,
      required this.type,
      required this.title,
      required this.participantIds,
      required this.lastMessageId});

  String toJson() {
    return jsonEncode({
      'id': id,
      'type': type,
      'title': title,
      'participant_ids': participantIds,
      'lastMessage_id': lastMessageId
    });
  }

  Object toObject() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'participant_ids': participantIds,
      'lastMessage_id': lastMessageId
    };
  }
}
