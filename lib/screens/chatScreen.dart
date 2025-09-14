import 'dart:async';

import 'package:chat_app/controllers/chatController.dart';
import 'package:chat_app/controllers/mergeStreamController.dart';
import 'package:chat_app/controllers/messagesController.dart';
import 'package:chat_app/controllers/userController.dart';
import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/messages.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/providers/textProvider.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_scroll/text_scroll.dart';

class ChatScreen extends ConsumerStatefulWidget {
  ChatScreen({super.key, required this.chat, required this.me});
  Chat chat;
  User me;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final List<Message> _cachedMessages = [];
  Timer timer = Timer(const Duration(seconds: 90), () {});
  FocusNode focusNode = FocusNode();

  MessagesController messagesController = MessagesController();
  UserController userController = UserController();
  TextEditingController messageController = TextEditingController();
  ChatsController chatsController = ChatsController();
  bool isOnline = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    messageController.dispose();
    chatsController.setTyping(widget.chat, false);
    timer.cancel();
    super.dispose();
  }

  String prevText = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(28, 156, 158, 255),
      appBar: AppBar(
        title: ListTile(
          leading: Hero(
            tag: 'pfp',
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage:
                  widget.chat.friend.profilePictureUrl == '' ||
                      widget.chat.friend.profilePictureUrl == null
                  ? const AssetImage(
                      'assets/images/chatApp ui ux/icons8-user-50.png',
                    )
                  : NetworkImage(widget.chat.friend.profilePictureUrl!),
            ),
          ),
          title: Text(
            widget.chat.friend.username,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          subtitle: StatefulBuilder(
            builder: (context, setState) {
              timer = Timer.periodic(const Duration(seconds: 90), (timer) {
                if (isOnline && mounted) setState(() {});
              });
              print('aa');
              return StreamBuilder(
                stream: combineStreams(
                  userController.streamUser(widget.chat.friend.id),
                  chatsController.getIsTyping(widget.chat, widget.me.id),
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData ||
                      snapshot.data == null) {
                    return const SizedBox();
                  }
                  isOnline = snapshot.data!.data1.getLastActive() == 'Online';
                  bool isTyping = snapshot.data!.data2;
                  return TextScroll(
                    isTyping
                        ? 'Typing...'
                        : snapshot.data!.data1.getLastActive(),
                    intervalSpaces: 10,
                    style: const TextStyle(fontSize: 14),
                    velocity: const Velocity(pixelsPerSecond: Offset(30, 0)),
                    pauseBetween: const Duration(seconds: 1),
                  );
                },
              );
            },
          ),
        ),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          Expanded(
            child: StreamBuilder(
              stream: combineStreams(
                messagesController.getMessages(widget.chat),
                userController.streamUser(widget.chat.friend.id),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  if (_cachedMessages.isNotEmpty)
                    return buildChatBubbles(_cachedMessages);

                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.data1.isEmpty) {
                  if (_cachedMessages.isNotEmpty)
                    return buildChatBubbles(_cachedMessages);
                  return Center(
                    child: Text(
                      'Start Chatting',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                final messagesData = snapshot.data!.data1;
                final userData = snapshot.data!.data2;

                _cachedMessages
                  ..clear()
                  ..addAll(messagesData);

                return buildChatBubbles(messagesData);
              },
            ),
          ),

          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Transform.rotate(
                    angle: 200,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.attachment, size: 30),
                      color: Colors.grey,
                    ),
                  ),
                ),
                Consumer(
                  builder: (context, ref, _) => SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: TextField(
                      controller: messageController,
                      focusNode: focusNode,
                      onChanged: (value) {
                        ref.read(textProvider.notifier).setText(value);
                        if (value.isEmpty) {
                          chatsController.setTyping(widget.chat, false);
                        }
                        if (value.isNotEmpty && prevText.isEmpty) {
                          chatsController.setTyping(widget.chat, true);
                        }
                        prevText = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.emoji_emotions_outlined,
                      size: 28,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, _) {
                      String text = ref.watch(textProvider);
                      return IconButton(
                        onPressed: text.trim().isEmpty
                            ? null
                            : () {
                                FocusScope.of(context).unfocus();
                                messageController.clear();
                                String send = text.trim();
                                ref.read(textProvider.notifier).setText('');

                                Message message = Message(
                                  content: send,
                                  timeSent: DateTime.now(),
                                  from: widget.me,
                                  to: widget.chat.friend,
                                  id: '',
                                  isSeen: false,
                                );

                                messagesController.sendMessage(
                                  widget.chat,
                                  message,
                                  widget.me,
                                );
                              },
                        icon: Icon(
                          Icons.send,
                          size: 28,
                          color: text.isEmpty ? Colors.grey : Colors.blue,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding buildChatBubbles(List<Message> messagesData) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ListView.builder(
        reverse: true,
        itemCount: messagesData.length,
        itemBuilder: (context, index) {
          final message = messagesData[messagesData.length - 1 - index];

          bool isDay = false;

          if (index == messagesData.length - 1) {
            isDay = true;
          } else {
            final prevMessage = messagesData[messagesData.length - 2 - index];
            final prevMessageDate = DateTime(
              prevMessage.timeSent.year,
              prevMessage.timeSent.month,
              prevMessage.timeSent.day,
            );
            final messageDate = DateTime(
              message.timeSent.year,
              message.timeSent.month,
              message.timeSent.day,
            );
            if (messageDate.difference(prevMessageDate).inDays >= 1) {
              isDay = true;
            }
          }

          if (message.to.id == widget.me.id && !message.isSeen) {
            messagesController.setSeen(widget.chat, widget.me, message);
          }

          return Column(
            children: [
              if (isDay) Center(child: Text(message.getDate())),
              BubbleNormal(
                seen: message.isSeen,
                sent: true,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                  minHeight: 55,
                ),
                time: Text(
                  message.getTime(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                text: message.content,
                isSender: message.from.id == widget.me.id,
                color: message.from.id == widget.me.id
                    ? const Color(0xFF1B97F3)
                    : const Color.fromARGB(28, 156, 158, 255),
                tail: true,
                textStyle: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }
}
