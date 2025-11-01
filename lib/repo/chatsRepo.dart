import 'dart:async';
import 'dart:developer';

import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/messages.dart';
import 'package:chat_app/models/user.dart' show User;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;

class ChatsRepo {
  StreamSubscription? _chatsSubscription;
  final StreamController<List<Map<String, dynamic>>> _chatsController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  CollectionReference? get fireStore {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('chats');
  }

  Stream<List<Map<String, dynamic>>> getChats() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("🔥 No authenticated user, returning empty stream");
      // Cancel any existing subscription first
      _chatsSubscription?.cancel();
      return Stream.value([]);
    }

    final store = fireStore;
    if (store == null) {
      print("🔥 No firestore access, returning empty stream");
      return Stream.value([]);
    }

    // Cancel any existing subscription before creating a new one
    _chatsSubscription?.cancel();

    print("🔥 Setting up new chats stream for user: ${currentUser.uid}");

    _chatsSubscription = store
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .listen(
          (snapShot) {
            final data = snapShot.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
            print("🔥 Chats snapshot received: ${data.length} chats");

            if (!_chatsController.isClosed) {
              _chatsController.add(data);
            }
          },
          onError: (error) {
            print("🔥 Chats stream error: $error");
            if (!_chatsController.isClosed) {
              _chatsController.addError(error);
            }
          },
          onDone: () {
            print("🔥 Chats stream closed");
          },
        );

    return _chatsController.stream;
  }

  Future<List<Map<String, dynamic>>> getChatsForUser(User user) async {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.id)
        .collection("chats")
        .get();

    return usersSnapshot.docs.map((e) => e.data()).toList();
  }

  Future<void> saveChat(Chat chat, User me) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('No authenticated user');
    }

    final store = fireStore;
    if (store == null) {
      throw Exception('Unable to access user chats');
    }

    final docRef = chat.id == '1' ? store.doc() : store.doc(chat.id);
    chat.id = docRef.id;
    await docRef.set(chat.toJson(), SetOptions(merge: true));

    Chat friendChat = Chat(
      isDeleted: false,
      id: chat.id,
      title: chat.title,
      friend: me,
      lastMessage: chat.lastMessage,
      isTyping: false,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(chat.friend.id)
        .collection('chats')
        .doc(chat.id)
        .set(friendChat.toJson());
  }

  Future<Map<String, dynamic>> getChat(User friend) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return {};
    }

    final store = fireStore;
    if (store == null) {
      return {};
    }

    try {
      final res = await store
          .where('friend.id', isEqualTo: friend.id)
          .limit(1)
          .get();
      final data = res.docs.isNotEmpty ? res.docs.first.data() : {};
      return Map<String, dynamic>.from(data as Map<String, dynamic>);
    } catch (e) {
      print('Error getting chat: $e');
      return {};
    }
  }

  // Add a dispose method to properly clean up resources
  void dispose() {
    print("🔥 Disposing ChatsRepo - cancelling subscription");
    _chatsSubscription?.cancel();
    _chatsController.close();
  }

  Future<void> setTyping(Chat chat, bool value) async {
    if (chat.id == '1') {
      print('its 1');
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(chat.friend.id)
          .collection('chats')
          .doc(chat.id)
          .update({'isTyping': value});
    } catch (e) {
      print(e);
    }
  }

  Stream<bool> isTypingStream(Chat chat, String id) {
    if (id == "") return Stream.value(false);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('chats')
        .doc(chat.id)
        .snapshots()
        .map((doc) {
          final data = doc.data();
          if (data == null) return false;
          return data['isTyping'] ?? false;
        });
  }

  Future<void> deleteChat(String id) async {
    await fireStore!.doc(id).delete();
  }

  Future<void> updateLastMessage(
    Chat chat,
    Message message, {
    required bool forFriend,
  }) async {
    log(chat.id);
    await fireStore!.doc(chat.id).set({
      'lastMessage': message.toJson(),
    }, SetOptions(merge: true));
    if (forFriend) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(chat.friend.id)
          .collection('chats')
          .doc(chat.id)
          .set({'lastMessage': message.toJson()}, SetOptions(merge: true));
    }
  }

  Future<void> setDeleted(bool isDeleted, Chat chat) async {
    if (isDeleted)
      await _deleteCollection(fireStore!.doc(chat.id).collection('messages'));
    await fireStore!.doc(chat.id).update({'isDeleted': isDeleted});
  }

  Future<void> _deleteCollection(
    CollectionReference collectionRef, {
    int batchSize = 20,
  }) async {
    QuerySnapshot snapshot = await collectionRef.limit(batchSize).get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();

    await _deleteCollection(collectionRef, batchSize: batchSize);
  }
}
