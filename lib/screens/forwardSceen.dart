import 'package:chat_app/controllers/chatController.dart';
import 'package:chat_app/controllers/messagesController.dart';
import 'package:chat_app/controllers/userController.dart';
import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/messages.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/screens/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Forwardsceen extends StatefulWidget {
  Forwardsceen({super.key, required this.user, required this.messages});
  User user;
  List<Message> messages;
  @override
  State<Forwardsceen> createState() => _ForwardsceenState();
}

class _ForwardsceenState extends State<Forwardsceen> {
  bool isLoading = true;
  UserController userController = UserController();
  ChatsController chatsController = ChatsController();
  MessagesController messagesController = MessagesController();
  List<Chat> chats = [];
  List<Chat> selected = [];
  @override
  void initState() {
    super.initState();
    initChats();
  }

  void initChats() async {
    chats = await chatsController.getChatsForUser(widget.user);
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: selected.isNotEmpty
          ? FloatingActionButton(
              child: const Icon(Icons.forward_sharp),
              onPressed: () {
                messagesController.forwardMessages(
                  widget.user,
                  widget.messages,
                  selected,
                );

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(user: widget.user),
                  ),
                  (route) => false,
                );
              },
            )
          : null,
      backgroundColor: const Color.fromARGB(28, 156, 158, 255),
      appBar: AppBar(
        title: Text(
          'Halo',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w800),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    if (!selected.contains(chats[index]))
                      selected.add(chats[index]);
                    else
                      selected.remove(chats[index]);
                    setState(() {});
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      boxShadow: const [BoxShadow(offset: Offset(2, 2))],
                      color: selected.contains(chats[index])
                          ? const Color.fromARGB(255, 1, 31, 84)
                          : const Color.fromARGB(255, 28, 28, 28),
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(chats[index].friend.username),
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage:
                                  chats[index].friend.profilePictureUrl == '' ||
                                      chats[index].friend.profilePictureUrl ==
                                          null
                                  ? const AssetImage(
                                      'assets/images/chatApp ui ux/icons8-user-50.png',
                                    )
                                  : NetworkImage(
                                      chats[index].friend.profilePictureUrl!,
                                    ),
                            ),

                            Positioned(
                              bottom: 2,
                              right: 0,
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 200),
                                scale: selected.contains(chats[index]) ? 1 : 0,
                                child: const CircleAvatar(
                                  backgroundColor: Colors.blueAccent,
                                  radius: 8,
                                  child: Icon(
                                    Icons.check,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
