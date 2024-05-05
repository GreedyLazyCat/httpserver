/*
 * Сделать список чатрумов(их id) и соответствующих им
 * вебсокет каналов.
 * Формат сообщения от пользователя:
 * {
 *  "type": "message/initial", тип сообщения
 *  "token": "askdlfj" !!! ЕСЛИ intial
 *  "key": "RSA public key" !!! ЕСЛИ initial публичный ключ шифрования
 *  "chatroom_id": "id", id чатрума куда нужно отправить собщение
 *  "text": "message text" текст сообщения
 * }
 * Формат ответа от сервера:
 * {
 *  "type": "error/message/initial", тип сообщения сервер error - нельзя ответить
 *  "key": "RSA public key" !!! ЕСЛИ initial
 *  "chatroom_id": "id", id чат рума куда отправмить, если error - этого поля
 *  "text": "message text/error text"
 * }
 */

import 'dart:convert';

import 'package:httpserver/models/message.dart';

enum ServerErrorCodes{
  WRONG_RSA_KEY,
  UNAUTHARIZED,
  WRONG_DATA_FORMAT
}

final class ServerResponse {

  static String generateChatMessage(Message message){
    return jsonEncode({
      'type': 'message',
      'id': message.id,
      'author_id': message.authorId,
      'chatroom_id': message.chatroomId,
      'body': message.body
    });
  }

  static String generateInitialMessage(String rsaKey){
    return jsonEncode({
      'type': 'initial',
      'rsakey': rsaKey
    });
  }

  static String generateErrorMessage(ServerErrorCodes code) {
    return jsonEncode({
      'type': 'error',
      'body': code.name
    });
  }
}
