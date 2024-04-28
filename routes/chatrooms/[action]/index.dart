import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:httpserver/authentificator.dart';
import 'package:httpserver/repository/virtual_db.dart';

Future<Response> onRequest(RequestContext context, String action) async {
  final request = context.request;
  final db = VirtualDB();

  switch (action){
    case 'create':
      final body = jsonDecode(await request.body()) as Map<String, dynamic>;
      final participantIds = body['participant_ids'] as List<dynamic>;
      await db.createChatRoom(participantIds.cast<String>());
      return Response(body: 'added');
    case 'get':
      final params = request.uri.queryParameters;
      
  }
  return Response(body: action);
}
