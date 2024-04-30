import 'dart:math';

import 'package:httpserver/exceptions/no_user_with_this_login.dart';
import 'package:httpserver/exceptions/user_with_this_login_exists.dart';
import 'package:httpserver/exceptions/wrong_password_exception.dart';
import 'package:httpserver/interface/chat_room_repo_interface.dart';
import 'package:httpserver/interface/user_interface.dart';
import 'package:httpserver/models/chatroom.dart';
import 'package:httpserver/models/message.dart';
import 'package:httpserver/models/user.dart';
import 'package:httpserver/random_key.dart';

class VirtualDB implements IUserRepository, IChatRoomRepository {
  final List<User> users = [
    User(id: 'first', login: 'admin', password: '1234'),
    User(id: 'second', login: 'antoha', password: 'gangsta')
  ];

  final List<Chatroom> chatrooms = [
    Chatroom(
        id: 'first',
        participantIds: ['first', 'second'],
        lastMessageId: 'first',
        title: 'none',
        type: 'pm')
  ];

  final List<Message> messages = [];

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

  @override
  Future<void> addMessageToChatRoom({required Message message}) async {
    messages.add(message);
  }

  @override
  Future<void> createChatRoom(
      String title, List<String> participantIds, String type) async {
    final chatroomId = generateRandomId(10);
    chatrooms.add(Chatroom(
        id: chatroomId,
        type: type,
        title: title,
        participantIds: participantIds,
        lastMessageId: null));
  }

  @override
  Future<List<Message>> getChatRoomMessages(String chatroomId) async {
    final messageList = List<Message>.empty();
    for (var message in messages) {
      if (message.chatroomId == chatroomId) {
        messageList.add(message);
      }
    }
    return messageList;
  }

  @override
  Future<List<String>> getChatroomsByParticipantId(String participantId) async {
    List<String> result = List.empty(growable: true);
    for (Chatroom chatroom in chatrooms) {
      if (chatroom.participantIds.contains(participantId)) {
        result.add(chatroom.id);
      }
    }
    return result;
  }

  ///Вспомогательная функция
  String generateRandomId(int len) {
    var r = Random();
    return String.fromCharCodes(
        List.generate(len, (index) => r.nextInt(33) + 89));
  }

  @override
  Future<void> createUser(
      {required String login, required String password}) async {
    for (var user in users) {
      if (user.login == login) {
        throw UserWithThisLoginExists();
      }
    }
    users.add(User(id: generateRandomId(6), login: login, password: password));
  }

  @override
  Future<Chatroom> getChatroomById(String chatroomId) {
    // TODO: implement getChatroomById
    throw UnimplementedError();
  }
}
