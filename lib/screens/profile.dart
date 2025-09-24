import 'package:chat_app/models/user.dart';
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
            children: [
              const SizedBox(height: 15),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.transparent,
                          backgroundImage:
                              widget.user.profilePictureUrl == '' ||
                                  widget.user.profilePictureUrl == null
                              ? const AssetImage(
                                  'assets/images/chatApp ui ux/icons8-user-50.png',
                                )
                              : NetworkImage(widget.user.profilePictureUrl!),
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
            ],
          ),
        ),
      ),
    );
  }
}
