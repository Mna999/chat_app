import 'package:chat_app/models/messages.dart';
import 'package:chat_app/models/user.dart';

class Chat {
  User friend;
  String id;
  String title;
  Message? lastMessage;

  Chat({
    required this.id,
    required this.title,
    required this.friend,
    this.lastMessage,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      title: json['title'],
      friend: User.fromJson(json['friend']),
      lastMessage:
          json['lastMessage'] != null &&
              (json['lastMessage'] as Map<String, dynamic>).isNotEmpty
          ? Message.fromJson(json['lastMessage'])
          : Message(
              content: '',
              timeSent: DateTime.now(),
              from: User(id: '', username: '', email: ''),
              to: User(id: '', username: '', email: ''),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'friend': friend.toJson(),
      'lastMessage': lastMessage != null ? lastMessage!.toJson() : {},
    };
  }


}
