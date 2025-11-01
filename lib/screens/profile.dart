import 'package:chat_app/controllers/AuthController.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/screens/editBottomSheet.dart';
import 'package:chat_app/screens/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Profile extends StatefulWidget {
  Profile({super.key, required this.isMine, required this.user});
  bool isMine;
  User user;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  AuthController authController = AuthController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(28, 156, 158, 255),
      appBar: AppBar(
        title: Text(
          'Halo',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Hero(
                                  tag: "pfp",
                                  child: Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.blue,
                                        width: 2,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: CircleAvatar(
                                      radius: 70,

                                      backgroundColor: Colors.transparent,
                                      backgroundImage:
                                          widget.user.profilePictureUrl == '' ||
                                              widget.user.profilePictureUrl ==
                                                  null
                                          ? const AssetImage(
                                              'assets/images/chatApp ui ux/icons8-user-50.png',
                                            )
                                          : NetworkImage(
                                              widget.user.profilePictureUrl!,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              if (widget.isMine)
                                Positioned(
                                  bottom: 0,
                                  right: 0,

                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.transparent
                                        .withAlpha(50),
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.camera_alt),
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          Center(
                            child: ListTile(
                              title: Center(
                                child: Text(
                                  widget.user.username,
                                  textAlign: TextAlign.center,

                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              subtitle: Center(
                                child: Text(widget.user.bio ?? '...'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 12,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Details",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        ListTile(
                          title: Text(
                            widget.user.username,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 20),
                          ),
                          subtitle: Text(widget.user.bio ?? '...'),
                          trailing: widget.isMine
                              ? CircleAvatar(
                                  backgroundColor: Colors.transparent.withAlpha(
                                    50,
                                  ),
                                  radius: 20,
                                  child: IconButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) => Padding(
                                          padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(
                                              context,
                                            ).viewInsets.bottom,
                                          ),
                                          child: SizedBox(
                                            height:
                                                MediaQuery.of(
                                                  context,
                                                ).size.height *
                                                0.55,
                                            child: Editbottomsheet(
                                              user: widget.user,
                                              state: () {
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.edit),
                                    color: Colors.blueAccent,
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              if (widget.isMine)
                ElevatedButton(
                  onPressed: () async {
                    await authController.logOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Loginscreen()),
                      (route) => true,
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Logout", style: TextStyle(fontSize: 17)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
