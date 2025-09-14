import 'package:chat_app/controllers/AuthController.dart';
import 'package:chat_app/controllers/userController.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/providers/ThemeModeProvider.dart';
import 'package:chat_app/providers/loadingProviderAuth.dart';
import 'package:chat_app/screens/loginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpscreen extends ConsumerStatefulWidget {
  const SignUpscreen({super.key});

  @override
  ConsumerState<SignUpscreen> createState() => _SignUpscreenState();
}

class _SignUpscreenState extends ConsumerState<SignUpscreen> {
  AuthController authController = AuthController();
  GlobalKey<FormState> formKey = GlobalKey();
  String username = '';
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    bool isLoading = ref.watch(loadingAuthProvider);
    final isLoadingRef = ref.read(loadingAuthProvider.notifier);
    bool isDark = ref.watch(themeModeProvider.notifier).isDark();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(themeModeProvider.notifier).toggleTheme();
        },
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.15,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Image.asset(
                    fit: BoxFit.contain,
                    isDark
                        ? 'assets/images/chatApp ui ux/Selection(dark).png'
                        : 'assets/images/chatApp ui ux/Selection.png',
                    scale: 0.5,
                  ),

                  Text(
                    'Create Your Account',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Join Halo today to connect with friends and family, it\'s quick and easy',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 50),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(hintText: 'Username'),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      String val = value ?? '';
                      if (val.trim().isEmpty) {
                        return 'Please fill your username';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      username = newValue ?? '';
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'Email'),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      String val = value ?? '';
                      if (val.trim().isEmpty) {
                        return 'Please fill your email';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      email = newValue ?? '';
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: const InputDecoration(hintText: 'Password'),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      String val = value ?? '';
                      if (val.trim().isEmpty) {
                        return 'Please fill your password';
                      }
                      if (val.trim().length <= 5) {
                        return 'Password should be at least 6 characters';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      password = value;
                      setState(() {});
                    },
                    onSaved: (newValue) {
                      password = newValue ?? '';
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: const InputDecoration(
                      hintText: 'confirm password',
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,

                    validator: (value) {
                      String val = value ?? '';
                      if (password != val) {
                        return 'Doesn\'t match password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,

                                    content: const Text(
                                      'Please fill the form correctly',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              } else {
                                try {
                                  formKey.currentState!.save();
                                  isLoadingRef.set();
                                  await authController.signUp(email.trim(), password.trim());
                                  isLoadingRef.reset();
                                  User user = User(
                                    email: email.trim(),
                                    id: authController
                                        .fireBaseAuth
                                        .currentUser!
                                        .uid,
                                    username: username.trim(),
                                    profilePictureUrl: '',
                                    lastActive: DateTime.now(),
                              
                                    
                                  );
                                  await UserController().saveUser(user);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Loginscreen(),
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      content: const Text(
                                        'A verification email was sent to you',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                } on FirebaseAuthException catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      content: Text(
                                        e.message ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                  isLoadingRef.reset();
                                }
                              }
                            },
                      child: const Text('SignUp'),
                    ),
                  ),

                  const SizedBox(height: 0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? '),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => Loginscreen(),
                                  ),
                                );
                              },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                          minimumSize: Size.zero,
                        ),
                        child: const Text('SignIn'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
