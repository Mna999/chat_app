import 'dart:async';
import 'dart:developer';

import 'package:chat_app/controllers/chatController.dart';
import 'package:chat_app/controllers/mergeStreamController.dart';
import 'package:chat_app/controllers/messagesController.dart';
import 'package:chat_app/controllers/userController.dart';
import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/messages.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/providers/textProvider.dart';
import 'package:chat_app/screens/chatBubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:url_launcher/url_launcher.dart';

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

  MessagesController messagesController = MessagesController();
  UserController userController = UserController();
  TextEditingController messageController = TextEditingController();
  ChatsController chatsController = ChatsController();
  bool isOnline = true;
  FocusNode focusNode = FocusNode();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    if (mounted) {
      chatsController.setTyping(widget.chat, false);
    }
    focusNode.dispose();
    timer.cancel();
    super.dispose();
  }

  List<Message> selected = [];
  String prevText = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(28, 156, 158, 255),
      appBar: AppBar(
        centerTitle: false,
        actions: selected.isNotEmpty
            ? [
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete'),
                        content: const Text(
                          'Are you sure you want to delete this message ?',
                        ),
                        actions: [
                          if (!selected.any(
                                (element) => element.from.id != widget.me.id,
                              ) &&
                              !selected.any((element) => element.isDeleted))
                            TextButton(
                              onPressed: () {
                                for (var message in selected) {
                                  messagesController.deleteForAll(
                                    widget.chat,
                                    message.id,
                                  );

                                  if (message.id ==
                                      widget.chat.lastMessage!.id) {
                                    message.isDeleted = true;
                                    chatsController.updateLastMessage(
                                      widget.chat,
                                      message,
                                      forFriend: true,
                                    );
                                  }
                                }
                                selected.clear();

                                setState(() {});

                                Navigator.pop(context);
                              },
                              child: const Text('Delete for everyone'),
                            ),
                          TextButton(
                            onPressed: () async {
                              for (var message in selected) {
                                messagesController.deleteForMe(
                                  widget.chat,
                                  message.id,
                                );
                              }

                              final remainingMessages = _cachedMessages
                                  .where(
                                    (m) => !selected.any((s) => s.id == m.id),
                                  )
                                  .toList();

                              if (remainingMessages.isNotEmpty) {
                                if (selected.any(
                                  (s) => s.id == widget.chat.lastMessage?.id,
                                )) {
                                  chatsController.updateLastMessage(
                                    widget.chat,
                                    remainingMessages.last,
                                    forFriend: false,
                                  );
                                }
                              } else {
                                chatsController.setIsDeleted(true, widget.chat);
                              }

                              selected.clear();
                              setState(() {});
                              Navigator.pop(context);
                            },
                            child: const Text('Delete for me'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
                if (selected.length == 1 &&
                    !selected.any(
                      (element) => element.from.id != widget.me.id,
                    ) &&
                    !selected.any((element) => element.isDeleted))
                  IconButton(
                    onPressed: () {
                      messageController.text = selected.first.content;
                      ref
                          .read(textProvider.notifier)
                          .setText(selected.first.content);
                      focusNode.requestFocus();

                      isEditing = true;
                      setState(() {});
                    },
                    icon: const Icon(Icons.edit, color: Colors.blue),
                  ),

                if (selected.length == 1 && !selected.first.isDeleted)
                  IconButton(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: selected.first.content),
                      );
                      selected.clear();
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Copied to clipboard!")),
                      );
                    },
                    icon: const Icon(Icons.copy),
                  ),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                ),
              ]
            : [],
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
            overflow: TextOverflow.ellipsis,
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
                if (widget.chat.id == '1') {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      widget.chat.id = FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.me.id)
                          .collection('chats')
                          .doc()
                          .id;
                    });
                  });
                }

                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  if (_cachedMessages.isNotEmpty)
                    return buildChatBubbles(_cachedMessages);

                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.data1.isEmpty) {
                  if (_cachedMessages.isNotEmpty) {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (mounted &&
                          (_cachedMessages.isNotEmpty &&
                              snapshot.data?.data1.isEmpty == true)) {
                        setState(() {
                          _cachedMessages.clear();
                        });
                      }
                    });
                    return buildChatBubbles(_cachedMessages);
                  }

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
                        if (value.isEmpty && _cachedMessages.isNotEmpty) {
                          chatsController.setTyping(widget.chat, false);
                        }
                        if (value.isNotEmpty &&
                            prevText.isEmpty &&
                            _cachedMessages.isNotEmpty) {
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
                            : () async {
                                FocusScope.of(context).unfocus();
                                messageController.clear();
                                String send = text.trim();
                                ref.read(textProvider.notifier).setText('');
                                if (!isEditing) {
                                  Message message = Message(
                                    content: send,
                                    isDeleted: false,
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
                                  if (widget.chat.isDeleted) {
                                    chatsController.setIsDeleted(
                                      false,
                                      widget.chat,
                                    );
                                  }
                                } else {
                                  Message message = selected.first;
                                  message.content = send;
                                  messagesController.editMessage(
                                    widget.chat,
                                    message,
                                    send,
                                  );
                                  if (message.id ==
                                      widget.chat.lastMessage!.id) {
                                    log('entered');
                                    log(send);
                                    chatsController.updateLastMessage(
                                      widget.chat,
                                      message,
                                      forFriend: true,
                                    );
                                  }
                                  chatsController.setTyping(widget.chat, false);

                                  selected.clear();
                                  isEditing = false;
                                  setState(() {});
                                }
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
              InkWell(
                onTap: () {
                  if (selected.isNotEmpty) {
                    if (selected.any((element) => element.id == message.id)) {
                      selected.removeWhere(
                        (element) => element.id == message.id,
                      );
                    } else {
                      selected.add(message);
                    }
                    setState(() {});
                  }
                },
                onLongPress: () {
                  if (selected.isEmpty) {
                    selected.add(message);
                    setState(() {});
                  }
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: selected.any((element) => element.id == message.id)
                        ? Colors.blue.withAlpha(155)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: selected.any((element) => element.id == message.id)
                        ? Border.all(color: Colors.blueAccent, width: 2)
                        : null,
                  ),
                  child: BubbleNormal(
                    seen: message.isDeleted ? false : message.isSeen,

                    sent: message.isDeleted ? false : true,
                    constraints: const BoxConstraints(
                      maxWidth: 300,
                      minWidth: 130,
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
                    isSender: message.from.id == widget.me.id,
                    color: message.from.id == widget.me.id
                        ? const Color(0xFF1B97F3)
                        : const Color.fromARGB(28, 156, 158, 255),
                    tail: true,
                    child: Linkify(
                      text: message.isDeleted
                          ? '🚫 This message was deleted'
                          : message.content,
                      style: const TextStyle(fontSize: 16),
                      linkStyle: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                      onOpen: (link) async {
                        final url = Uri.parse(link.url);
                        if (!await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        )) {
                          throw Exception('Could not launch $url');
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
