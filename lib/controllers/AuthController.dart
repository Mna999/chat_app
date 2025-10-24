import 'dart:async';

import 'package:chat_app/controllers/userController.dart';
import 'package:chat_app/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:google_sign_in/google_sign_in.dart';

class AuthController {
  final fireBaseAuth = FirebaseAuth.instance;
  UserController userController = UserController();

  Future<void> signUp(String email, String password) async {
    try {
      await fireBaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await verifyAcc();
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  Future<void> logIn(String email, String password) async {
    try {
      await fireBaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  Future<void> logOut() async {
    await fireBaseAuth.signOut();
    await GoogleSignIn().signOut();
  }

  Future<bool> googleSignIn() async {
    GoogleSignInAccount? acc = await GoogleSignIn().signIn();
    if (acc == null) return false;

    final GoogleSignInAuthentication googleAuth = await acc.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential = await fireBaseAuth.signInWithCredential(
      credential,
    );

    final tUser = await userController.getUserById(userCredential.user!.uid);
    if (tUser == null) {
      final User user = User(
        id: userCredential.user!.uid,
        username: userCredential.user!.displayName ?? '',
        email: userCredential.user!.email ?? '',
        profilePictureUrl: '',
        lastActive: DateTime.now(),
        bio: '',
      );
      await userController.saveUser(user);
    }
    return true;
  }

  Future<void> resetPassword(String email) async {
    await fireBaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> verifyAcc() async {
    final user = fireBaseAuth.currentUser;
    if (user == null) return;

    await user.reload();
    if (user.emailVerified) {
      print('User already verified');
      return;
    }

    await user.sendEmailVerification();

    print('Verification email sent!');
  }
}
