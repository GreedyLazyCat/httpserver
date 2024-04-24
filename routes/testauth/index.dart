import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:httpserver/models/user.dart';

Response onRequest(RequestContext context) {
  final user = context.read<User>();
  if (user == null) {
    return Response(statusCode: HttpStatus.unauthorized);
  }
  // TODO: implement route handler
  return Response(body: 'This is a new route!');
}
