import 'package:chat_app/controllers/AuthController.dart';
import 'package:chat_app/controllers/chatController.dart';
import 'package:chat_app/controllers/userController.dart';
import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/screens/chatScreen.dart';
import 'package:chat_app/screens/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserController userController = UserController();
  AuthController authController = AuthController();
  ChatsController chatsController = ChatsController();
  User user = User(id: '', username: '', email: '');
  bool isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    user = await userController.loadUser();
    setState(() {});
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
                user,
              );

              if (results.isEmpty) {
                return [const ListTile(title: Text('No users found'))];
              }

              return results.map((friend) {
                return ListTile(
                  title: Text(friend.username),
                  subtitle: Text(friend.email),
                  onTap: () async {
                    Chat? res = await chatsController.getChat(friend);
                    Chat chat = res ?? Chat(id: '1', title: '', friend: friend);
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(chat: chat, me: user),
                      ),
                    );
                  },
                );
              });
            },
          ),
        ],

        leading: IconButton(
          onPressed: () async {
            isLoggingOut = true;
            setState(() {});
            await authController.logOut();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Loginscreen()),
            );
          },
          icon: const Icon(Icons.exit_to_app_outlined),
          iconSize: 30,
        ),
      ),
      body: isLoggingOut
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder(
              stream: chatsController.getChats(),
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
                          subtitle: Text(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            snapshot.data![index].lastMessage!.from.id ==
                                    user.id
                                ? ' me : ${snapshot.data![index].lastMessage!.content}'
                                : '${snapshot.data![index].lastMessage!.from.username} : ${snapshot.data![index].lastMessage!.content}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: Text(
                            snapshot.data![index].lastMessage!.getDate2(),
                            style: const TextStyle(color: Colors.grey),
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
                                  me: user,
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
