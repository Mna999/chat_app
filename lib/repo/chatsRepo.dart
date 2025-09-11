import 'dart:async';

import 'package:chat_app/models/chat.dart';
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

    _chatsSubscription = store.snapshots().listen(
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
}
