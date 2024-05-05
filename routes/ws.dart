import 'dart:async';
import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:httpserver/authentificator.dart';
import 'package:httpserver/encryption/encrypt.dart';
import 'package:httpserver/interface/chat_room_repo_interface.dart';
import 'package:httpserver/models/message.dart';
import 'package:httpserver/models/user.dart';
import 'package:httpserver/repository/virtual_db.dart';
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
 */

final Map<String, List<WebSocketChannel>> chatrooms = {};
final Map<String, WebSocketChannel> connections = {};

void broadcast(List<String> userIds, String sender, String data) {
  for (var userId in userIds) {
    if (userId != sender && connections.containsKey(userId)) {
      connections[userId]!.sink.add(data);
    }
  }
}

Future<Response> onRequest(RequestContext context) async {
  final auth = context.read<Authentificator>();
  var state = 0;
  final db = VirtualDB();
  User? user;
  final handler = webSocketHandler((channel, protocol) {
    channel.stream.listen(
      (event) async {
        switch (state) {
          case 0:
            // final decryptedString =
            // await deryptString(event as String, await secretKey);
            final body = jsonDecode(event as String) as Map<String, dynamic>;
            user = await auth.tokenIsValid(body['token'] as String);
            if (user != null) {
              //---------------deprecated-------------
              final chatRoomRepo = auth.repo as IChatRoomRepository;
              final userChatrooms =
                  await chatRoomRepo.getChatroomsByParticipantId(user!.id);
              for (var chatroom in userChatrooms) {
                if (!chatrooms.containsKey(chatroom.id)) {
                  chatrooms.addAll({
                    chatroom.id: [channel]
                  });
                } else {
                  chatrooms[chatroom.id]!.add(channel);
                }
              }
              //--------------------------------------
              connections.addAll({user!.id: channel});
              state++;
              print('authorized successfully');
            }

          case 1:
            // final decryptedString =
            // await deryptString(event as String, await secretKey);
            final message = event as String;
            final messageJson = jsonDecode(message) as Map<String, dynamic>;

            switch (messageJson['type']) {
              case 'message':
                final chatroomId = messageJson['chatroom_id'] as String;
                final participantIds =
                    (messageJson['participant_ids'] as List<dynamic>)
                        .map((e) => e as String)
                        .toList();
                final chatMessage = Message(
                    id: db.generateRandomId(10),
                    chatroomId: messageJson['chatroom_id'] as String,
                    authorId: user!.id,
                    body: messageJson['body'] as String);

                unawaited(db.addMessageToChatRoom(
                    authorId: user!.id,
                    chatroomId: chatroomId,
                    body: messageJson['body'] as String));

                broadcast(
                  participantIds,
                  user!.id,
                  ServerResponse.generateChatMessage(chatMessage),
                );
              case 'new_chatroom':
                final participantIds =
                    (messageJson['participant_ids'] as List<dynamic>)
                        .map((e) => e as String)
                        .toList();
                await db.createChatRoom(messageJson['title'] as String,
                    participantIds, messageJson['chatroom_type'] as String);
                print(participantIds);
                broadcast(participantIds, user!.id, '{"type": "new_chatroom"}');
            }
        }
      },
      onDone: () {
        for (var chatroomId in chatrooms.keys) {
          chatrooms[chatroomId]!.remove(channel);
        }
      },
    );
  });

  return handler(context);
}
