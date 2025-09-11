import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/repo/chatsRepo.dart';

class ChatsController {
  ChatsRepo chatsRepo = ChatsRepo();

  Future<void> saveChat(Chat chat, User me) async {
    await chatsRepo.saveChat(chat, me);
  }

  Stream<List<Chat>> getChats() {
    return chatsRepo.getChats().map(
      (event) => event.map((e) => Chat.fromJson(e)).toList(),
    );
  }

  Future<Chat?> getChat(User friend) async {
    final json = await chatsRepo.getChat(friend);
    if (json.isEmpty)
      return null;
    else
      return Chat.fromJson(json);
  }
}
