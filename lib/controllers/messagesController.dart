import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/messages.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/repo/messagesRepo.dart';

class MessagesController {
  MessagesRepo messagesRepo = MessagesRepo();

  void sendMessage(Chat chat, Message message, User me) async {
    await messagesRepo.addMessage(chat, message, me);
  }

  void setSeen(Chat chat, User me, Message message) async {
    await messagesRepo.setSeen(chat, me, message);
  }

  Stream<List<Message>> getMessages(Chat chat) {
    return messagesRepo.getMessages(chat).map((event) {
      final messages = event.map((e) {
        final msg = Message.fromJson(e);
        return msg;
      }).toList();
      return messages;
    });
  }
}
