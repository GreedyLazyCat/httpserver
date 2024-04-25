import 'dart:convert';

import 'package:crypton/crypton.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:httpserver/authentificator.dart';
import 'package:httpserver/server_response_generator.dart';
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
 * 
 * Логика такая - сервер отправляет публичный ключ шифрования
 * клиент отправляет свой токен авторизации и свой публичный ключ,
 * в уже зашифрованном виде.
 */

final Map<String, List<WebSocketChannel>> chatrooms = {};
final Map<WebSocketChannel, RSAKeypair> channelKeys = {};
final Map<WebSocketChannel, RSAPublicKey> clientKeys = {};

Future<Response> onRequest(RequestContext context) async {
  final auth = context.read<Authentificator>();
  var initPhase = true;
  final handler = webSocketHandler((channel, protocol) {
    channel.stream.listen((event) async {
      if (!channelKeys.containsKey(channel)) {
        final pair = RSAKeypair.fromRandom();
        channelKeys.addAll({channel: pair});
      }

      final keyPair = channelKeys[channel];

      if (initPhase) {
        final message = event as String;

        if (message.isNotEmpty) {
          try {
            //base64Decode(message).;

            final publicKey = RSAPublicKey.fromString(message);
            clientKeys.addAll({channel: publicKey});
            channel.sink.add(keyPair!.publicKey.toString());
            initPhase = !initPhase;
          } on FormatException {
            channel.sink.add(ServerErrorCodes.WRONG_RSA_KEY.name);
          } catch (e){
            channel.sink.add(ServerErrorCodes.WRONG_RSA_KEY.name);
          }
        } else {
          channel.sink.add(ServerErrorCodes.WRONG_RSA_KEY.name);
        }
      } else {
        //Блок выполняется после обмена ключами
        final clientPublicKey = clientKeys[channel];
        try {
          final decrypted = keyPair!.privateKey.decrypt(event as String);

          var user = await auth.tokenIsValid(decrypted);
          if (user != null) {
            channel.sink.add('authorized successfully');
          } else {
            final serverMessage = clientPublicKey!.encrypt(
                ServerResponseGenerator.generateErrorMessage(
                    ServerErrorCodes.UNAUTHARIZED));
            channel.sink.add(serverMessage);
          }
        } on FormatException {
          channel.sink.add('encryption error');
        }
      }
    });
  });
  return handler(context);
}
