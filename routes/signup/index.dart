import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:httpserver/authentificator.dart';
import 'package:httpserver/models/user.dart';
import 'package:httpserver/random_key.dart';

Future<Response> onRequest(RequestContext context) async {
  // TODO: implement route handler
  final request = context.request;
  final authInMethod = context.read<Authentificator>();
  var body = await request.body();

  if (request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final bodyDecoded = jsonDecode(body) as Map<String, dynamic>;
    if (!bodyDecoded.containsKey('login') ||
        !bodyDecoded.containsKey('password')) {
      return Response(
          statusCode: HttpStatus.badRequest,
          body: 'No login or password field');
    }

    await authInMethod.repo.createUser(
        login: bodyDecoded['login'] as String,
        password: bodyDecoded['password'] as String);

    return Response(body: '');
  } on FormatException {
    return Response(statusCode: HttpStatus.badRequest, body: 'Bad data format');
  }
}
