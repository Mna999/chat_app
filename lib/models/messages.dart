import 'package:chat_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum MessageType { text, image, video, file, audio }

class Message {
  String content;
  DateTime timeSent;
  User from;
  User to;
  MessageType messageType;
  bool isSeen;
  String id;
  bool isDeleted;

  Message({
    required this.content,
    required this.timeSent,
    required this.from,
    required this.to,
    required this.isSeen,
    required this.id,
    required this.isDeleted,
    this.messageType = MessageType.text,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'] ?? '',
      timeSent: (json['timeSent'] as Timestamp).toDate(),
      isSeen: json['isSeen'] as bool,
      from: User.fromJson(json['from']),
      to: User.fromJson(json['to']),
      id: json['id'],
      isDeleted: json['isDeleted'],
      messageType: MessageType.text,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'from': from.toJson(),
      'to': to.toJson(),
      'id': id,
      'isSeen': isSeen,
      'isDeleted': isDeleted,
      'messageType': 'text',
      'timeSent': Timestamp.fromDate(timeSent),
    };
  }

  String getDate() {
    DateTime now = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    DateTime time = DateTime(timeSent.year, timeSent.month, timeSent.day);

    int diffDays = now.difference(time).inDays;

    if (diffDays == 0) {
      // 🔹 Today → show "Today at <time>"

      return 'Today at ${DateFormat.jm().format(timeSent)}';
      // e.g. Today at 3:45 PM
    } else if (diffDays == 1) {
      return 'Yesterday at ${DateFormat.jm().format(timeSent)}';
      // e.g. Yesterday at 8:20 PM
    } else if (now.year == timeSent.year) {
      // Same year → show date + time
      return '${DateFormat('MMM d').format(timeSent)} at ${DateFormat.jm().format(timeSent)}';
      // e.g. Sep 10 at 4:10 PM
    } else {
      // Different year → full date + time
      return '${DateFormat('MMM d, yyyy').format(timeSent)} at ${DateFormat.jm().format(timeSent)}';
      // e.g. Sep 10, 2024 at 7:30 AM
    }
  }

  String getDate2() {
    DateTime now = DateTime.now();
    int diffDays = now.difference(timeSent).inDays;

    if (diffDays == 0) {
      // 🔹 Today → show "Today at <time>"
      return DateFormat.jm().format(timeSent);
      // e.g. Today at 3:45 PM
    } else if (diffDays == 1) {
      return 'Yesterday';
      // e.g. Yesterday at 8:20 PM
    } else if (now.year == timeSent.year) {
      // Same year → show date + time
      return DateFormat('MMM d').format(timeSent);
      // e.g. Sep 10 at 4:10 PM
    } else {
      // Different year → full date + time
      return DateFormat('MMM d, yyyy').format(timeSent);
      // e.g. Sep 10, 2024 at 7:30 AM
    }
  }

  String getTime() {
    return DateFormat.jm().format(timeSent);
  }
}
