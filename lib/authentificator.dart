import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:httpserver/models/user.dart';
import 'package:httpserver/repository/user_interface.dart';
import 'package:httpserver/repository/virtual_user_repo.dart';

class Authentificator {
  IUserRepository repo = VirtualUserRepo();
  final signKey = 'zbKAqX58(J?gwZ4rnFM#t;';//change

  // final static Authentificator

  ///Получает токен пользователя по его [login] и [password]
  ///В случае если аутентификационные данные неверные
  ///возвращает null
  Future<String?> getAuthToken(String login, String password) async {
    final user = await repo.getOneByPasswordAndLogin(login, password);
    if (user == null) {
      return null;
    }

    final jwt = JWT({'id': user.id, 'login': user.login});
    final token = jwt.sign(SecretKey(signKey));
    return token;
  }

  //Сделать так, чтобы метод возвращал не только валидность токена,
  //но и причину невалидности, если это так
  Future<User?> tokenIsValid(String token) async {
    try {
      // Verify a token (SecretKey for HMAC & PublicKey for all the others)
      final jwt = JWT.verify(token, SecretKey(signKey));
      final payload = jwt.payload as Map<String, dynamic>;

      if (payload.containsKey('id')) {
        final id = payload['id'] as String;
        final user = await repo.getOneById(id);
        return user;
      }
    } on JWTException {
      return null;
    }
    return null;
  }
}
