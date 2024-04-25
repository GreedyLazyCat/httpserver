import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:httpserver/authentificator.dart';
/*
 * Сделать список чатрумов(их id) и соответствующих им
 * вебсокет каналов.
 * Формат сообщения от пользователя:
 * {
 *  "type": "message", тип сообщения
 *  "chatroom_id": "id", id чатрума куда нужно отправить собщение
 *  "text": "message text" текст сообщения
 * }
 * Формат ответа от сервера:
 * {
 *  "type": "error/message", тип сообщения сервер error - нельзя ответить
 *  "chatroom_id": "id", id чат рума куда отправмить, если error - этого поля нет
 * 
 *  "text": "message text/error text"
 * }
 */
Future<Response> onRequest(RequestContext context) async {
  final auth = context.read<Authentificator>();
  var fisrtMessage = true;
  final handler = webSocketHandler((channel, protocol) {
    channel.stream.listen((event) async {
      if (fisrtMessage) {
        var user = await auth.tokenIsValid(event as String);
        if (user != null) {
          fisrtMessage = false;
          channel.sink.add('authorized successfully');
        } else {
          channel.sink.add('token is invalid');
        }
      } else {
        channel.sink.add('authorized successfully');
      }
    });
  });
  return handler(context);
}
