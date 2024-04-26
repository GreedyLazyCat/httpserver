import 'dart:convert';

import 'package:crypton/crypton.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:encrypt/encrypt.dart';
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
final Map<WebSocketChannel, RSAKeypair> channelRSAKeys = {};
//Заменить на ключи AES
final Map<WebSocketChannel, RSAPublicKey> clientKeys = {};
final Map<WebSocketChannel, Key> channelAESKeys = {};


Future<Response> onRequest(RequestContext context) async {
  final auth = context.read<Authentificator>();
  // var initPhase = true;
  var state = 0;
  final handler = webSocketHandler((channel, protocol) {
    channel.stream.listen((event) async {
      if (!channelRSAKeys.containsKey(channel)) {
        final pair = RSAKeypair.fromRandom();
        channelRSAKeys.addAll({channel: pair});
      }

      final keyPair = channelRSAKeys[channel];

      switch (state) {
        case 0:
          final message = event as String;

          if (message.isNotEmpty) {
            try {
              //base64Decode(message).;

              final publicKey = RSAPublicKey.fromString(message);
              clientKeys.addAll({channel: publicKey});
              channel.sink.add(keyPair!.publicKey.toString());
              // initPhase = !initPhase;
              state++;
            } on FormatException {
              channel.sink.add(ServerErrorCodes.WRONG_RSA_KEY.name);
            } catch (e) {
              channel.sink.add(ServerErrorCodes.WRONG_RSA_KEY.name);
            }
          } else {
            channel.sink.add(ServerErrorCodes.WRONG_RSA_KEY.name);
          }
        case 1:
          final encrypted = event as String;
          if (encrypted == 'success') {
            state++;
            // print('succsess');
            return;
          }

          final decrypted = keyPair!.privateKey.decrypt(encrypted);
          channel.sink.add(decrypted);

        case 2:
          final clientPublicKey = clientKeys[channel];
          try {
            final decrypted = keyPair!.privateKey.decrypt(event as String);
            // print(decrypted);
            var user = await auth.tokenIsValid(decrypted);
            if (user != null) {
              channel.sink.add(clientKeys[channel]!.encrypt('authorized successfully'));
              state++;
            } else {
              final serverMessage = clientPublicKey!.encrypt(
                  ServerResponseGenerator.generateErrorMessage(
                      ServerErrorCodes.UNAUTHARIZED));
              channel.sink.add(serverMessage);
            }
          } catch (e) {
            channel.sink.add('encryption error');
          }
      }
      /*
      if (initPhase) {
        
      } else {
        //Блок выполняется после обмена ключами
        
      }*/
    });
  });
  return handler(context);
}
