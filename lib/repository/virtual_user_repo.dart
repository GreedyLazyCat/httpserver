import 'package:httpserver/models/user.dart';
import 'package:httpserver/repository/no_user_with_this_login.dart';
import 'package:httpserver/repository/user_interface.dart';
import 'package:httpserver/repository/wrong_password_exception.dart';

class VirtualUserRepo implements IUserRepository {
  List<User> users = [
    User(id: 'first', login: 'admin', password: '1234'),
    User(id: 'second', login: 'antoha', password: 'gangsta')
  ];

  static final VirtualUserRepo repo = VirtualUserRepo._generateSingleton();

  VirtualUserRepo._generateSingleton();

  factory VirtualUserRepo() {
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
