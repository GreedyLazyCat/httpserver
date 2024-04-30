import 'dart:convert';

class User {
  User({required this.id, required this.login, required this.password});

  final String id;
  final String login;
  final String password;

  String toJson() {
    return jsonEncode({'id': id, 'login': login, 'password': password});
  }
}
