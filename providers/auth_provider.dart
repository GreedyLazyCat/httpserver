import 'package:dart_frog/dart_frog.dart';
import 'package:httpserver/authentificator.dart';
import 'package:httpserver/repository/virtual_user_repo.dart';

Authentificator auth = Authentificator(VirtualDB());

Middleware authProvider() {
  return provider<Authentificator>((context) => auth);
}
