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
}
