import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:httpserver/models/message.dart';
import 'package:httpserver/models/user.dart';
import 'package:httpserver/repository/virtual_db.dart';

/*
 * Формат create {'participant_ids': [...], 'title': ...}
 * Формат read - просто авторизированный запрос
 * Формат readone - {'chatroom_id': ... }
 */
Future<Response> onRequest(RequestContext context, String action) async {
  final request = context.request;
  final db = VirtualDB();

  switch (action) {
    case 'create':
      final body = jsonDecode(await request.body()) as Map<String, dynamic>;
      final participantIds = body['participant_ids'] as List<dynamic>;
      if (participantIds.length > 2) {
        await db.createChatRoom(
            body['title'] as String, participantIds.cast<String>(), 'group');
      } else {
        await db.createChatRoom('none', participantIds.cast<String>(), 'pm');
      }

      return Response(body: 'added');
    case 'read':
      final user = context.read<User>();
      final chatrooms = await db.getChatroomsByParticipantId(user.id);
      final body = {'chatrooms': []};
      for (var chatroom in chatrooms) {
        body['chatrooms']!.add(chatroom.toObject());
      }
      return Response(body: jsonEncode(body));
    case 'readone':
      final body = jsonDecode(await request.body()) as Map<String, dynamic>;
      final chatroom = await db.getChatroomById(body['chatroom_id'] as String);
      if (chatroom == null) {
        return Response(
            statusCode: HttpStatus.badRequest,
            body: 'there is no such chatroom');
      }
      return Response(body: chatroom.toJson());
  }
  return Response(body: action);
}
