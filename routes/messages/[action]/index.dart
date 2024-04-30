import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:httpserver/models/message.dart';
import 'package:httpserver/repository/virtual_db.dart';


/*
 * Формат read {'chatroom_id': ... }
 * Формат create {'chatroom_id': ..., 'author_id': ..., 'body': ...} 
 */

Future<Response> onRequest(
  RequestContext context,
  String action,
) async {
  final db = VirtualDB();
  final request = context.request;
  switch (action) {
    case 'get':
      final body = jsonDecode(await request.body()) as Map<String, dynamic>;
      final messages =
          await db.getChatRoomMessages(body['chatroom_id'] as String);
      var response = {'messages': []};

      for (var message in messages) {
        response['messages']!.add(message.toObject());
      }
      return Response(body: jsonEncode(response));
    case 'read':
      final body = jsonDecode(await request.body()) as Map<String, dynamic>;
      final message = Message(
          chatroomId: body['chatroom_id'] as String,
          authorId: body['author_id'] as String,
          body: body['body'] as String);
      await db.addMessageToChatRoom(message: message);
  }
  return Response(body: 'This is a new route!');
}
