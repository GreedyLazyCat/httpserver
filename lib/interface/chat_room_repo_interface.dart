/*
 * Для виртуального репозитория:
 * Список чатрумов представить как Map<chatroomId, List<participantIds>>
 * Список сообщений
 */
import 'package:httpserver/models/message.dart';

abstract class IChatRoomRepository {
  Future<void> createChatRoom(List<String> participantIds);
  Future<List<Message>> getChatRoomMessages(String chatroomId);
  Future<List<String>> getChatroomsByParticipantId(String participantId);
  Future<void> addMessageToChatRoom({required Message message});
}
