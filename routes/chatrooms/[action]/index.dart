import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:httpserver/models/message.dart';
import 'package:httpserver/repository/virtual_db.dart';

/*
 * Когда action=read:
 *  Если тип chatrooms возвращаем все чатрумы в которых учавствует
 *  user с userId
 *  Если тип  
 */
Future<Response> onRequest(RequestContext context, String action) async {
  final request = context.request;
  final db = VirtualDB();

  switch (action) {
    case 'create':
      final body = jsonDecode(await request.body()) as Map<String, dynamic>;
      final participantIds = body['participant_ids'] as List<dynamic>;
      await db.createChatRoom(participantIds.cast<String>());
      return Response(body: 'added');
    case 'read':
      final params = request.uri.queryParameters;
      final type = params['type'];
      if (type == 'chatrooms') {
        final chatrooms =
            await db.getChatroomsByParticipantId(params['userId']!);
        return Response(body: jsonEncode({'chatroom_ids': chatrooms}));
      }
      if (type == 'messages') {
        final messages = await db.getChatRoomMessages(params['chatroomId']!);
        final body = {'messages': List<String>.empty(growable: true)};
        for (Message message in messages){
          body['messages']!.add(message.toJson());
        }
        return Response(body: jsonEncode(body));
      }
  }
  return Response(body: action);
}
