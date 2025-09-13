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
    String messageId = fireStore.doc(chat.id).collection('messages').doc().id;
    message.id = messageId;
    chat.lastMessage = message;
    chat.lastMessage!.isSeen = false;

    await ChatsController().saveChat(chat, me);

    await fireStore.doc(chat.id).collection('messages').doc(message.id).set({
      ...message.toJson(),
      'timeSent': FieldValue.serverTimestamp(),
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(chat.friend.id)
        .collection('chats')
        .doc(chat.id)
        .collection('messages')
        .doc(message.id)
        .set({...message.toJson(), 'timeSent': FieldValue.serverTimestamp()});
  }

  Future<void> setSeen(Chat chat, User me, Message message) async {
    await ChatsController().saveChat(chat, me);
    await fireStore.doc(chat.id).collection('messages').doc(message.id).update({
      'isSeen': true,
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(chat.friend.id)
        .collection('chats')
        .doc(chat.id)
        .collection('messages')
        .doc(message.id)
        .update({'isSeen': true});
  }

  Stream<List<Map<String, dynamic>>> getMessages(Chat chat) {
    return fireStore
        .doc(chat.id)
        .collection('messages')
        .orderBy('timeSent', descending: false)
        .snapshots()
        .map((snapShot) {
          final data = snapShot.docs.map((e) {
            final message = e.data();

            return message;
          }).toList();
          return data;
        });
  }
}
