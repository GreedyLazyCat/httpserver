/*
 * Для виртуального репозитория:
 * Список чатрумов представить как Map<chatroomId, List<participantIds>>
 * Список сообщений
 */
import 'package:httpserver/models/chatroom.dart';
import 'package:httpserver/models/message.dart';

///Репозиторий чатрумов
abstract class IChatRoomRepository {
  /// Создает чатрум, на вход принимает изначальные id участников
  Future<void> createChatRoom(
      String title, List<String> participantIds, String type);

  ///Получает сообщения принадлежащие чатруму с id [chatroomId]
  Future<List<Message>> getChatRoomMessages(String chatroomId);

  ///Получает список чатрумов по [participantId] участника.
  ///[return] список чатрумов.
  Future<List<Chatroom>> getChatroomsByParticipantId(String participantId);

  ///Добавить сообщение в чатрум
  Future<void> addMessageToChatRoom(
      {required String chatroomId, required String authorId, required String body});

  Future<Chatroom?> getChatroomById(String chatroomId);

  Future<Message?> getMessageById(String messageId);
}
