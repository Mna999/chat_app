import 'dart:async';

import 'package:chat_app/controllers/AuthController.dart';
import 'package:chat_app/controllers/chatController.dart';
import 'package:chat_app/controllers/messagesController.dart';
import 'package:chat_app/controllers/presenceHandler.dart';
import 'package:chat_app/controllers/userController.dart';
import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/screens/chatScreen.dart';
import 'package:chat_app/screens/loginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key, required this.user});
  User user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserController userController = UserController();
  AuthController authController = AuthController();
  ChatsController chatsController = ChatsController();
  MessagesController messagesController = MessagesController();

  bool isLoggingOut = false;
  final PresenceHandler _presenceHandler = PresenceHandler();

  // Add a StreamSubscription to manage the chats stream
  StreamSubscription? _chatsSubscription;
  final StreamController<List<Chat>> _chatsStreamController =
      StreamController<List<Chat>>.broadcast();

  @override
  void initState() {
    super.initState();
    loadUser();
    _setupChatsStream();
  }

  void loadUser() {
    _presenceHandler.init(widget.user);
    setState(() {});
  }

  void _setupChatsStream() {
    _chatsSubscription = chatsController.getChats().listen(
      (chats) {
        if (!_chatsStreamController.isClosed) {
          _chatsStreamController.add(chats);
        }
      },
      onError: (error) {
        print('Chats stream error: $error');
        if (!_chatsStreamController.isClosed) {
          _chatsStreamController.addError(error);
        }
      },
    );
  }

  @override
  void dispose() {
    // Cancel the subscription and close the stream controller
    _presenceHandler.dispose();
    _chatsSubscription?.cancel();
    _chatsStreamController.close();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    setState(() {
      isLoggingOut = true;
    });
    _presenceHandler.dispose();

    try {
      // Cancel the chats subscription first
      await _chatsSubscription?.cancel();
      _chatsSubscription = null;

      // Close the stream controller
      if (!_chatsStreamController.isClosed) {
        _chatsStreamController.close();
      }

      // Now log out
      await authController.logOut();

      // Navigate to login screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Loginscreen()),
        );
      }
    } catch (e) {
      print('Logout error: $e');
      setState(() {
        isLoggingOut = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(28, 156, 158, 255),
      appBar: AppBar(
        title: Text(
          'Halo',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w800),
        ),
        actions: [
          SearchAnchor(
            builder: (context, controller) {
              return IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  controller.openView();
                },
              );
            },
            suggestionsBuilder: (context, controller) async {
              if (controller.text.isEmpty) {
                return [
                  const ListTile(title: Text('Type a username to search')),
                ];
              }

              final results = await userController.searchUser(
                controller.text.toLowerCase(),
                widget.user,
              );

              if (results.isEmpty) {
                return [const ListTile(title: Text('No users found'))];
              }

              return results.map((friend) {
                return ListTile(
                  title: Text(friend.username),
                  subtitle: Text(friend.email),
                  leading: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage:
                        friend.profilePictureUrl == '' ||
                            friend.profilePictureUrl == null
                        ? const AssetImage(
                            'assets/images/chatApp ui ux/icons8-user-50.png',
                          )
                        : NetworkImage(friend.profilePictureUrl!),
                  ),
                  onTap: () async {
                    Chat? res = await chatsController.getChat(friend);
                    Chat chat =
                        res ??
                        Chat(
                          isDeleted: false,
                          id: FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.user.id)
                              .collection('chats')
                              .doc()
                              .id,
                          title: '',
                          friend: friend,
                          isTyping: false,
                        );
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatScreen(chat: chat, me: widget.user),
                      ),
                    );
                  },
                );
              });
            },
          ),
        ],
        leading: IconButton(
          onPressed: _handleLogout,
          icon: const Icon(Icons.exit_to_app_outlined),
          iconSize: 30,
        ),
      ),
      body: isLoggingOut
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder(
              stream: _chatsStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print('StreamBuilder error: ${snapshot.error}');
                  return Center(
                    child: Text(
                      'Error loading chats',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Start new conversations',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) => Card(
                        child: ListTile(
                          title: Text(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            snapshot.data![index].friend.username,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: StreamBuilder(
                            stream: chatsController.getIsTyping(
                              snapshot.data![index],
                              widget.user.id,
                            ),
                            builder: (context, asyncSnapshot) {
                              return Text(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                asyncSnapshot.data != null &&
                                        asyncSnapshot.connectionState ==
                                            ConnectionState.active &&
                                        asyncSnapshot.data!
                                    ? 'Typing...'
                                    : snapshot
                                          .data![index]
                                          .lastMessage!
                                          .isDeleted
                                    ? '🚫 This message was deleted'
                                    : snapshot
                                              .data![index]
                                              .lastMessage!
                                              .from
                                              .id ==
                                          widget.user.id
                                    ? ' me : ${snapshot.data![index].lastMessage!.content}'
                                    : '${snapshot.data![index].lastMessage!.from.username} : ${snapshot.data![index].lastMessage!.content}',
                                style: TextStyle(
                                  color:
                                      asyncSnapshot.data != null &&
                                          asyncSnapshot.connectionState ==
                                              ConnectionState.active &&
                                          asyncSnapshot.data!
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              );
                            },
                          ),
                          trailing: StreamBuilder(
                            stream: messagesController.unseenCount(
                              snapshot.data![index],
                              widget.user,
                            ),
                            builder: (context, asyncSnapshot) {
                              return Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    snapshot.data![index].lastMessage!
                                        .getDate2(),
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  if (asyncSnapshot.data != null &&
                                      asyncSnapshot.data! > 0 &&
                                      asyncSnapshot.hasData &&
                                      asyncSnapshot.connectionState ==
                                          ConnectionState.active)
                                    CircleAvatar(
                                      radius: 12,
                                      child: asyncSnapshot.data! < 99
                                          ? Text(
                                              '${asyncSnapshot.data!}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            )
                                          : const Text(
                                              '99+',
                                              style: TextStyle(fontSize: 10),
                                            ),
                                    ),

                                  if (snapshot
                                              .data![index]
                                              .lastMessage!
                                              .from
                                              .id ==
                                          widget.user.id &&
                                      !snapshot
                                          .data![index]
                                          .lastMessage!
                                          .isDeleted &&
                                      !snapshot.data![index].isTyping)
                                    snapshot.data![index].lastMessage!.isSeen
                                        ? const Icon(
                                            Icons.done_all,
                                            color: Colors.blue,
                                            size: 17,
                                          )
                                        : const Icon(
                                            Icons.done,
                                            color: Colors.grey,
                                            size: 17,
                                          ),
                                ],
                              );
                            },
                          ),
                          leading: Hero(
                            tag: 'pfp',
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage:
                                  snapshot
                                              .data![index]
                                              .friend
                                              .profilePictureUrl ==
                                          '' ||
                                      snapshot
                                              .data![index]
                                              .friend
                                              .profilePictureUrl ==
                                          null
                                  ? const AssetImage(
                                      'assets/images/chatApp ui ux/icons8-user-50.png',
                                    )
                                  : NetworkImage(
                                      snapshot
                                          .data![index]
                                          .friend
                                          .profilePictureUrl!,
                                    ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  chat: snapshot.data![index],
                                  me: widget.user,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
    );
  }
}
