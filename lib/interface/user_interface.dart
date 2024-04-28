
import 'package:httpserver/models/user.dart';

abstract class IUserRepository {
  Future<List<User>> getAll();
  Future<User?> getOneById(String id);
  ///Реализация должна предусматривать вызов исключения [WrongPasswordException]
  /// в случае неправильного пароля и [NoUserWithThisLoginException], если
  /// нет такого пользователя 
  Future<User?> getOneByPasswordAndLogin(String login, String password);
  Future<void> createUser({required String login, required String password});
  Future<void> insert(User book);
  Future<void> update(User book);
  Future<void> delete(String id);
}
