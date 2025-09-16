import 'dart:convert';

import 'package:chat_app/models/messages.dart';
import 'package:chat_app/models/user.dart';

class Chat {
  User friend;
  String id;
  String title;
  Message? lastMessage;
  bool isTyping;
  bool isDeleted;

  Chat({
    required this.id,
    required this.title,
    required this.friend,
    required this.isDeleted,
    this.lastMessage,
    required this.isTyping,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(isDeleted: json['isDeleted'],
      id: json['id'],
      title: json['title'],
      friend: User.fromJson(json['friend']),
      lastMessage:
          json['lastMessage'] != null &&
              (json['lastMessage'] as Map<String, dynamic>).isNotEmpty
          ? Message.fromJson(json['lastMessage'])
          : Message(
              isSeen: false,
              id: '',
              content: '',
              isDeleted: false,
              timeSent: DateTime.now(),
              from: User(
                id: '',
                username: '',
                email: '',
                lastActive: DateTime.now(),
              ),
              to: User(
                id: '',
                username: '',
                email: '',
                lastActive: DateTime.now(),
                
              ),
              
            ),
      isTyping: json['isTyping'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'friend': friend.toJson(),
      'lastMessage': lastMessage != null ? lastMessage!.toJson() : {},
      'isTyping': isTyping,
      'isDeleted':isDeleted
    };
  }

  Chat copyWith({required Message lastMessage}) {
    return Chat(
      id: id,
      title: title,
      friend: friend,
      lastMessage: lastMessage,
      isTyping: isTyping,
      isDeleted: isDeleted
    );
  }
}
