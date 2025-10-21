import 'package:chat_app/controllers/AuthController.dart';
import 'package:chat_app/controllers/chatController.dart';
import 'package:chat_app/controllers/presenceHandler.dart';
import 'package:chat_app/controllers/userController.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/screens/homeScreen.dart';
import 'package:chat_app/screens/profile.dart';
import 'package:flutter/material.dart';

class HomescreenNav extends StatefulWidget {
  const HomescreenNav({super.key});

  @override
  State<HomescreenNav> createState() => _HomescreenNavState();
}

class _HomescreenNavState extends State<HomescreenNav> {
  UserController userController = UserController();
  AuthController authController = AuthController();
  ChatsController chatsController = ChatsController();
  User user = User(id: '', username: '', email: '', lastActive: DateTime.now());
  final PresenceHandler _presenceHandler = PresenceHandler();
  PageController pageController = PageController();
  @override
  void initState() {
    super.initState();    
    loadUser();
  }

  void loadUser() async {
    user = await userController.loadUser();

    _presenceHandler.init(user);
    setState(() {});
  }

  int index = 0;
  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      HomeScreen(user: user),
      Profile(isMine: true, user: user),
    ];
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: index,
        onTap: (value) {
          setState(() {
            index = value;
          });
          pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
          );
        },
      ),
      body: PageView(
        controller: pageController,
        children: screens,
        onPageChanged: (value) {
          index = value;
          setState(() {});
        },
      ),
    );
  }
}
