import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class User {
  String id;
  String username;
  String email;
  String? profilePictureUrl;
  String? bio;
  DateTime lastActive;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.lastActive,
    this.bio,
    this.profilePictureUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      profilePictureUrl: json['profilePictureUrl'],
      lastActive: json['lastSeen'] != null
          ? (json['lastSeen'] as Timestamp).toDate()
          : DateTime.now(),
      bio: json['bio'] ?? '...',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'bio': bio,
    };
  }

  String getLastActive() {
    DateTime now = DateTime.now();

    Duration diffDays = now.difference(lastActive);

    if (diffDays.inMinutes < 1) {
      return 'Online';
      // e.g. Today at 3:45 PM
    } else if (diffDays.inMinutes > 1 && diffDays.inDays < 1) {
      return 'Last Seen: Today at ${DateFormat.jm().format(lastActive)}';
    } else if (diffDays.inDays == 1) {
      return 'Last Seen: Yesterday at ${DateFormat.jm().format(lastActive)}';
      // e.g. Yesterday at 8:20 PM
    } else if (now.year == lastActive.year) {
      // Same year → show date + time
      return 'Last Seen: ${DateFormat('MMM d').format(lastActive)} at ${DateFormat.jm().format(lastActive)}';
      // e.g. Sep 10 at 4:10 PM
    } else {
      // Different year → full date + time
      return 'Last Seen: ${DateFormat('MMM d, yyyy').format(lastActive)} at ${DateFormat.jm().format(lastActive)}';
      // e.g. Sep 10, 2024 at 7:30 AM
    }
  }
}
