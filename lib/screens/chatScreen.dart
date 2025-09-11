import 'package:chat_app/controllers/messagesController.dart';
import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/messages.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/providers/textProvider.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends ConsumerStatefulWidget {
  ChatScreen({super.key, required this.chat, required this.me});
  Chat chat;
  User me;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  MessagesController messagesController = MessagesController();
  TextEditingController messageController = TextEditingController();
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
        ),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          Expanded(
            child: StreamBuilder(
              stream: messagesController.getMessages(widget.chat),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return Center(
                    child: Text(
                      'Start Chatting',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );

                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ListView.builder(
                    reverse: false,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      bool isDay = false;

                      if (index > 0) {
                        if (snapshot.data![index].timeSent.day !=
                            snapshot.data![index - 1].timeSent.day) {
                          isDay = true;
                        }
                      } else {
                        isDay = true;
                      }
                      return Column(
                        children: [
                          if (isDay)
                            Center(
                              child: Text(snapshot.data![index].getDate()),
                            ),
                          BubbleNormal(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                              minHeight: 55,
                            ),

                            time: Text(
                              snapshot.data![index].getTime(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            margin: const EdgeInsets.symmetric(vertical: 6),
                            text: snapshot.data![index].content,
                            isSender:
                                snapshot.data![index].from.id == widget.me.id,
                            color: snapshot.data![index].from.id == widget.me.id
                                ? const Color(0xFF1B97F3)
                                : const Color.fromARGB(28, 156, 158, 255),
                            tail: true,
                            textStyle: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: TextField(
                    controller: messageController,
                    onChanged: (value) {
                      ref.read(textProvider.notifier).setText(value);
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
                        onPressed: text.isEmpty
                            ? null
                            : () async {
                                FocusScope.of(context).unfocus();
                                messageController.clear();
                                String send = text;
                                ref.read(textProvider.notifier).setText('');

                                Message message = Message(
                                  content: send,
                                  timeSent: DateTime.now(),
                                  from: widget.me,
                                  to: widget.chat.friend,
                                );
                                await messagesController.sendMessage(
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
}
