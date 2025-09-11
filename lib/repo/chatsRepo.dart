import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/user.dart' show User;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;

class ChatsRepo {
  final fireStore = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('chats');

  Stream<List<Map<String, dynamic>>> getChats() {
    final res = fireStore.snapshots().map(
      (snapShot) => snapShot.docs.map((doc) => doc.data()).toList(),
    );

    // Debug log
    res.listen((data) {
      print("🔥 Chats snapshot:");
      for (var chat in data) {
        print(chat);
      }
    });

    return res;
  }

  Future<void> saveChat(Chat chat, User me) async {

    final docRef = chat.id == '1' ? fireStore.doc() : fireStore.doc(chat.id);
    chat.id = docRef.id;
    await docRef.set(chat.toJson(), SetOptions(merge: true));
    Chat friendChat = Chat(
      id: chat.id,
      title: chat.title,
      friend: me,
      lastMessage: chat.lastMessage,
    );
    await FirebaseFirestore.instance
        .collection('users')
        .doc(chat.friend.id)
        .collection('chats')
        .doc(chat.id)
        .set(friendChat.toJson());
  }

  Future<Map<String, dynamic>> getChat(User friend) async {
    final res = await fireStore
        .where('friend.id', isEqualTo: friend.id)
        .limit(1)
        .get();
    final data = res.docs.isNotEmpty ? res.docs.first.data() : {};
    return Map<String, dynamic>.from(data);
  }
}
