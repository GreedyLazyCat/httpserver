import 'package:dart_frog/dart_frog.dart';
import 'package:httpserver/authentificator.dart';

Authentificator auth = Authentificator();

Middleware authProvider() {
  return provider<Authentificator>((context) => auth);
}
