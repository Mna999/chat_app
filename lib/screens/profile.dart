import 'package:chat_app/controllers/AuthController.dart';
import 'package:chat_app/controllers/userController.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/providers/ThemeModeProvider.dart';
import 'package:chat_app/providers/loadingProviderAuth.dart';
import 'package:chat_app/screens/editBottomSheet.dart';
import 'package:chat_app/screens/loginScreen.dart';
import 'package:chat_app/screens/pfp.dart';
import 'package:chat_app/screens/pickImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class Profile extends ConsumerStatefulWidget {
  Profile({super.key, required this.isMine, required this.user});
  bool isMine;
  User user;

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  AuthController authController = AuthController();

  @override
  Widget build(BuildContext context) {
    bool isLoading = ref.watch(loadingAuthProvider);
    bool isDark = ref.watch(themeModeProvider.notifier).isDark();
    return Scaffold(
      backgroundColor: isDark
          ? const Color.fromARGB(28, 156, 158, 255)
          : const Color.fromARGB(244, 250, 246, 255),
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
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            Pfp(user: widget.user),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: "pfp",
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border:
                                            widget.user.profilePictureUrl !=
                                                    '' &&
                                                widget.user.profilePictureUrl !=
                                                    null
                                            ? Border.all(
                                                color: Colors.blue,
                                                width: 4,
                                              )
                                            : null,
                                        shape: BoxShape.circle,
                                      ),
                                      child: CircleAvatar(
                                        radius: 70,

                                        backgroundImage: const AssetImage(
                                          'assets/images/chatApp ui ux/icons8-user-50.png',
                                        ),
                                        backgroundColor: Colors.transparent,
                                        foregroundImage:
                                            widget.user.profilePictureUrl ==
                                                    '' ||
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
                              ),
                              if (widget.isMine)
                                Positioned(
                                  bottom: 0,
                                  right: 0,

                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor:
                                        ref
                                            .read(themeModeProvider.notifier)
                                            .isDark()
                                        ? Colors.transparent.withAlpha(20)
                                        : Colors.transparent.withAlpha(20),
                                    child: IconButton(
                                      onPressed: () async {
                                        final url = await showModalBottomSheet(
                                          isScrollControlled: true,
                                          isDismissible: !isLoading,
                                          context: context,
                                          builder: (context) =>
                                              Pickimage(user: widget.user),
                                        );
                                        UserController userController =
                                            UserController();
                                        if (url != null) {
                                          String? prev =
                                              widget.user.profilePictureUrl;
                                          widget.user.profilePictureUrl = url;
                                          setState(() {});

                                          userController.updateUserForFriends(
                                            widget.user,
                                          );
                                        }
                                      },
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
                        Text(
                          widget.isMine ? "Details And Appearance" : "Details",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
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
                                  backgroundColor:
                                      ref
                                          .read(themeModeProvider.notifier)
                                          .isDark()
                                      ? Colors.transparent.withAlpha(50)
                                      : Colors.transparent.withAlpha(20),
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
                        if (widget.isMine) const SizedBox(height: 20),
                        if (widget.isMine)
                          SwitchListTile(
                            title: const Text(
                              'Dark mode',
                              style: TextStyle(fontSize: 20),
                            ),
                            subtitle: const Text("turn on dark mode"),
                            value: isDark,
                            onChanged: (value) {
                              ref
                                  .read(themeModeProvider.notifier)
                                  .toggleTheme();
                              setState(() {});
                            },
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
                      MaterialPageRoute(
                        builder: (context) => const Loginscreen(),
                      ),
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
