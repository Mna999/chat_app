import 'dart:async';
import 'package:chat_app/controllers/userController.dart';
import 'package:chat_app/models/user.dart';
import 'package:flutter/widgets.dart';

class PresenceHandler with WidgetsBindingObserver {
  final UserController _userController = UserController();
  Timer? _heartbeatTimer;
  User? _currentUser;

  PresenceHandler();

  /// Initialize presence tracking
  void init(User user) {
    _currentUser = user;
    WidgetsBinding.instance.addObserver(this);

    _sendHeartbeat(); // ✅ Immediately mark active

    // Send heartbeat every 30s
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _sendHeartbeat();
    });
  }

  /// Stop presence tracking (manual logout)
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _heartbeatTimer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_currentUser == null) return;

    if (state == AppLifecycleState.resumed) {
      _sendHeartbeat(); // Back online immediately
    }
    // ⚠️ Do NOT set offline here — heartbeat will expire naturally
  }

  /// Always updates lastSeen + online heartbeat
  Future<void> _sendHeartbeat() async {
    if (_currentUser == null||_currentUser!.id=='') return;

    await _userController.saveUserDate(
      User(
        id: _currentUser!.id,
        username: _currentUser!.username,
        email: _currentUser!.email,
        profilePictureUrl: _currentUser!.profilePictureUrl,
        lastActive: DateTime.now(),
     
  
      ),
    );
  }
}
