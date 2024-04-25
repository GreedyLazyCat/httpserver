/*
 * Для виртуального репозитория:
 * Список чатрумов представить как Map<chatroomId, List<participantIds>>
 * Список сообщений
 */
import 'package:httpserver/models/message.dart';

///Репозиторий чатрумов
abstract class IChatRoomRepository {
  /// Создает чатрум, на вход принимает изначальные id участников
  Future<void> createChatRoom(List<String> participantIds);

  ///Получает сообщения принадлежащие чатруму с id [chatroomId]
  Future<List<Message>> getChatRoomMessages(String chatroomId);

  ///Получает список чатрумов по [participantId] участника.
  ///[return] список id чатрумов.
  Future<List<String>> getChatroomsByParticipantId(String participantId);

  ///Добавить сообщение в чатрум
  Future<void> addMessageToChatRoom({required Message message});
}
