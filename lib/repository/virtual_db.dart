import 'dart:math';

import 'package:httpserver/exceptions/no_user_with_this_login.dart';
import 'package:httpserver/exceptions/user_with_this_login_exists.dart';
import 'package:httpserver/exceptions/wrong_password_exception.dart';
import 'package:httpserver/interface/chat_room_repo_interface.dart';
import 'package:httpserver/interface/user_interface.dart';
import 'package:httpserver/models/chatroom.dart';
import 'package:httpserver/models/message.dart';
import 'package:httpserver/models/user.dart';

class VirtualDB implements IUserRepository, IChatRoomRepository {
  final List<User> users = [
    User(id: 'first', login: 'admin', password: '1234'),
    User(id: 'second', login: 'antoha', password: '1234'),
    User(id: 'third', login: 'dimas', password: '1234'),
  ];

  final List<Chatroom> chatrooms = [
    Chatroom(
        id: 'first',
        participantIds: ['first', 'second'],
        lastMessageId: 'first',
        title: 'none',
        type: 'pm'),
    Chatroom(
        id: 'second',
        participantIds: ['first', 'second', 'third'],
        lastMessageId: 'none',
        title: 'BestTitle',
        type: 'group')
  ];

  final List<Message> messages = [
    Message(
        id: 'first',
        chatroomId: 'first',
        authorId: 'first',
        body: 'Test message'),
    Message(
        id: 'second',
        chatroomId: 'first',
        authorId: 'second',
        body: 'Another test message')
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

  @override
  Future<void> addMessageToChatRoom(
      {required String chatroomId,
      required String authorId,
      required String body}) async {
    messages.add(Message(
        id: generateRandomId(10),
        chatroomId: chatroomId,
        authorId: authorId,
        body: body));
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
        lastMessageId: 'none'));
  }

  @override
  Future<List<Message>> getChatRoomMessages(String chatroomId) async {
    final messageList = List<Message>.empty(growable: true);
    for (var message in messages) {
      if (message.chatroomId == chatroomId) {
        messageList.add(message);
      }
    }
    return messageList;
  }

  @override
  Future<List<Chatroom>> getChatroomsByParticipantId(
      String participantId) async {
    List<Chatroom> result = List.empty(growable: true);
    for (var chatroom in chatrooms) {
      if (chatroom.participantIds.contains(participantId)) {
        result.add(chatroom);
      }
    }
    return result;
  }

  ///Вспомогательная функция
  String generateRandomId(int len) {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();

    return String.fromCharCodes(Iterable.generate(
    len, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
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
  Future<Chatroom?> getChatroomById(String chatroomId) async {
    for (var chatroom in chatrooms) {
      if (chatroom.id == chatroomId) {
        return chatroom;
      }
    }
    return null;
  }

  @override
  Future<Message?> getMessageById(String messageId) async {
    for (var message in messages) {
      if (message.id == messageId) {
        return message;
      }
    }
    return null;
  }
}
