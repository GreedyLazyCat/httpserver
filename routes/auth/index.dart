import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:httpserver/authentificator.dart';
import 'package:httpserver/exceptions/no_user_with_this_login.dart';
import 'package:httpserver/exceptions/wrong_password_exception.dart';

/*
 * Вид корректного запроса:
 *    POST-запрос
 * body содержит:
 *    поля login и password
 * Ответ: В случае если найден пользователь - токен авторизации,
 *        код ответа 200(ok)
 *        Если пользователь не найден - 401
 */

Future<Response> onRequest(RequestContext context) async {
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

    final token = await authInMethod.getAuthToken(
        bodyDecoded['login'] as String, bodyDecoded['password'] as String);

    return Response(body: jsonEncode({'token': token}));
  } on FormatException {
    return Response(statusCode: HttpStatus.badRequest, body: 'Bad data format');
  } on WrongPasswordException {
    return Response(statusCode: HttpStatus.badRequest, body: 'Wrong password');
  } on NoUserWithThisLoginException {
    return Response(
        statusCode: HttpStatus.badRequest, body: 'No user with such login');
  }

  // return Response(body: 'aaa');
}
