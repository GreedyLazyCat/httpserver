import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:httpserver/authentificator.dart';
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
 * TODO: добавить обмен AES ключем и шифровать им трафик
 * Алгоритм установления связи:
 * 1. Клиент отправляет свой публичный ключ
 * 2. Если все хорошо сервер отправляет свой публичный ключ
 *    и ожидает проверочного сообщения.
 * 3. Сервер расшифровывает это сообщение и отправляет назад.
 * 4. Если все правильно клиент отправит success. Сервер теперь ожидает токен
 *    аутентификации.
 * 5. Токен авторизации приходит, пользователь аутентифицируется.
 */

final Map<String, List<WebSocketChannel>> chatrooms = {};

Future<Response> onRequest(RequestContext context) async {
  final auth = context.read<Authentificator>();
  var state = 0;
  final handler = webSocketHandler((channel, protocol) {
    channel.stream.listen((event) async {
      if (state == 0) {
        var user = await auth.tokenIsValid(event as String);
        if (user != null) {
          state++;
          channel.sink.add('authorized successfully');
        }
      } else {}
    });
  });
  return handler(context);
}
