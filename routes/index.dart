import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  //final auth = context.read<Authentificator>();
  //auth.repo.insert(User(id: 'third', login: 'login', password: 'password'));
  return Response(body: 'Welcome to Dart Frog!');
}
