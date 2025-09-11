import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/messages.dart';
import 'package:chat_app/models/user.dart';

import 'package:chat_app/repo/messagesRepo.dart';

class MessagesController {
  MessagesRepo messagesRepo = MessagesRepo();

  Future<void> sendMessage(Chat chat, Message message,User me) async {
    await messagesRepo.addMessage(chat, message,me);
  }

  Stream<List<Message>> getMessages(Chat chat) {
    return messagesRepo
        .getMessages(chat)
        .map((event) => event.map((e) => Message.fromJson(e)).toList());
  }
}
