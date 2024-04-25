import 'package:dart_frog/dart_frog.dart';
import 'package:httpserver/authentificator.dart';
import 'package:httpserver/repository/virtual_db.dart';

Authentificator auth = Authentificator(VirtualDB());

Middleware authProvider() {
  return provider<Authentificator>((context) => auth);
}
