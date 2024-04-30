import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:httpserver/models/message.dart';
import 'package:httpserver/models/user.dart';
import 'package:httpserver/repository/virtual_db.dart';

/*
 * Формат create {'participant_ids': [...], 'title': ...}
 * Формат read - просто авторизированный запрос
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
      final chatrooms =
          await db.getChatroomsByParticipantId(user.id);
      return Response(body: jsonEncode({'chatroom_ids': chatrooms}));
  }
  return Response(body: action);
}
