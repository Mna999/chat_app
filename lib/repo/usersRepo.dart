import 'package:chat_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;

class UsersRepo {
  final fireStore = FirebaseFirestore.instance.collection('users');

  Future<void> saveUser(User user) async {
    await fireStore.doc(user.id).set({
      ...user.toJson(),
      'lowerCaseUser': user.username.toLowerCase(),
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveUserDate(User user) async {
    await fireStore.doc(user.id).set({
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateUserDataForChats(User user) async {
    await saveUser(user);
    final users = await fireStore.get();
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (final users in users.docs) {
      final chats = await users.reference
          .collection("chats")
          .where("friend.id", isEqualTo: user.id)
          .get();
      for (var chat in chats.docs) {
        await chat.reference.update({"friend": user.toJson()});
      }
    }
  }

  Future<Map<String, dynamic>> loadUser() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await fireStore
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (snapshot.exists)
      return snapshot.data() ?? {};
    else
      return {};
  }

  Future<List<Map<String, dynamic>>> search(String username) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('lowerCaseUser', isGreaterThanOrEqualTo: username)
        .where('lowerCaseUser', isLessThanOrEqualTo: '$username\uf8ff')
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.map((e) => e.data()).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> getUserById(String id) async {
    final snapshot = await fireStore.where('id', isEqualTo: id).limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return {};
  }

  Stream<Map<String, dynamic>> userStream(String id) {
    final snapshot = fireStore.doc(id).snapshots();
    return snapshot.map((event) => event.data() as Map<String, dynamic>);
  }
}
