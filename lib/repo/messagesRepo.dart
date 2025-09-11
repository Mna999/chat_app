import 'package:chat_app/controllers/chatController.dart';
import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/messages.dart';
import 'package:chat_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;

class MessagesRepo {
  final fireStore = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('chats');

  Future<void> addMessage(Chat chat, Message message, User me) async {
    chat.lastMessage = message;
    await ChatsController().saveChat(chat, me);

    await fireStore
        .doc(chat.id)
        .collection('messages')
        .doc()
        .set(message.toJson());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(chat.friend.id)
        .collection('chats')
        .doc(chat.id)
        .collection('messages')
        .doc()
        .set(message.toJson());
  }

  Stream<List<Map<String, dynamic>>> getMessages(Chat chat) {
    return fireStore
        .doc(chat.id)
        .collection('messages')
        .orderBy('timeSent', descending: false)
        .snapshots()
        .map((snapShot) => snapShot.docs.map((e) => e.data()).toList());
  }
}
