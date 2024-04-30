import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:httpserver/authentificator.dart';
import 'package:httpserver/exceptions/user_with_this_login_exists.dart';
import 'package:httpserver/models/user.dart';

Future<Response> onRequest(
  RequestContext context,
  String action,
) async {
  final request = context.request;
  final authInMethod = context.read<Authentificator>();
  var body = await request.body();

  switch (action) {
    case 'read':
      final user = context.read<User>();
      return Response(body: jsonEncode({'id': user.id, 'login': user.login}));
  }
  return Response(body: 'This is a new route!');
}
