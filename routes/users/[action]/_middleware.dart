import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:httpserver/authentificator.dart';
import 'package:httpserver/models/user.dart';

import '../../../providers/auth_provider.dart';

Handler middleware(Handler handler) {
  return handler.use(bearerAuthentication<User>(authenticator: (context, token) {
    final auth2 = context.read<Authentificator>();
    return auth2.tokenIsValid(token);
  })).use(authProvider());
}
