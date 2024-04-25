import 'package:httpserver/models/user.dart';
import 'package:httpserver/exceptions/no_user_with_this_login.dart';
import 'package:httpserver/interface/user_interface.dart';
import 'package:httpserver/exceptions/wrong_password_exception.dart';

class VirtualDB implements IUserRepository {
  List<User> users = [
    User(id: 'first', login: 'admin', password: '1234'),
    User(id: 'second', login: 'antoha', password: 'gangsta')
  ];

  static final VirtualDB repo = VirtualDB._generateSingleton();

  VirtualDB._generateSingleton();

  factory VirtualDB() {
    return repo;
  }

  @override
  Future<void> delete(String id) async {
    for (var user in users) {
      if (user.id == id) {
        users.remove(user);
        break;
      }
    }
  }

  @override
  Future<List<User>> getAll() async {
    return users;
  }

  @override
  Future<User?> getOneById(String id) async {
    for (var user in users) {
      if (user.id == id) {
        return user;
      }
    }
    return null;
  }

  @override
  Future<void> insert(User user) async {
    users.add(user);
  }

  ///Потом доделаю
  @override
  Future<void> update(User userToUpdate) async {
    throw UnimplementedError();
  }

  @override
  Future<User?> getOneByPasswordAndLogin(String login, String password) async {
    User? fetchedUser;
    for (var user in users) {
      if (user.login == login) {
        fetchedUser = user;
      }
    }
    if (fetchedUser == null) {
      throw NoUserWithThisLoginException();
    }
    if (fetchedUser.password != password) {
      throw WrongPasswordException();
    }
    return fetchedUser;
  }
}
